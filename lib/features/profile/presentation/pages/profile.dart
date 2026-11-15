import 'package:flutter/material.dart';
import '../profile_motion.dart';
export '../profile_motion.dart';
import 'package:natyapp/core/auth/authenticated_user.dart';
import 'package:natyapp/core/di/injection.dart';
import 'package:natyapp/core/network/api_client.dart';
import 'package:natyapp/core/router/app_routes.dart';
import 'package:natyapp/core/widgets/learning_path_loading.dart';
import 'package:natyapp/core/widgets/press_feedback.dart';
import 'package:natyapp/features/training/data/training_repository_api.dart';
import 'package:natyapp/features/training/domain/training.dart';
import 'package:natyapp/theme/app_colors.dart';
import '../../domain/profile_overview.dart';
import '../../../gamification/data/gamification_repository.dart';
import '../../../gamification/presentation/gamification_panel.dart';
import '../../data/profile_account_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.repository,
    this.identity,
    this.gamificationRepository,
    this.accountRepository,
  });
  final GamificationRepository? gamificationRepository;
  final TrainingRepository? repository;
  final AuthenticatedUser? identity;
  final ProfileAccountRepository? accountRepository;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<ProfileOverview> _future;
  ProfileOverview? _visible;
  GamificationRepository? _gamificationRepository;
  int _gamificationRevision = 0;
  ProfileAccountRepository? _accountRepository;
  AuthenticatedUser? _profileUser;
  bool _accountLoading = false;
  bool _accountFailed = false;

  @override
  void initState() {
    super.initState();
    _gamificationRepository =
        widget.gamificationRepository ??
        (getIt.isRegistered<ApiClient>()
            ? GamificationRepositoryApi(getIt<ApiClient>())
            : null);
    _future = _load();
    _accountRepository =
        widget.accountRepository ??
        (getIt.isRegistered<ApiClient>()
            ? ProfileAccountRepositoryApi(getIt<ApiClient>())
            : null);
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    if (_accountRepository == null) return;
    setState(() {
      _accountLoading = true;
      _accountFailed = false;
    });
    try {
      final user = await _accountRepository!.fetchAccount();
      if (mounted) {
        setState(() {
          _profileUser = user;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _accountFailed = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _accountLoading = false;
        });
      }
    }
  }

  Future<ProfileOverview> _load() async {
    final repository = widget.repository ?? getIt<TrainingRepository>();
    final tracks = await repository.fetchTracks();
    final progress = await Future.wait(
      tracks.map((track) => repository.fetchProgress(track.id)),
    );
    final overview = ProfileOverview(
      TrainingSection.sequence(tracks, progress),
    );
    _visible = overview;
    return overview;
  }

  Future<void> _refresh() async {
    final account = _loadAccount();
    final next = _load();
    setState(() {
      _future = next;
      _gamificationRevision++;
    });
    try {
      await Future.wait([next, account]);
    } catch (_) {
      /* Mantém os dados anteriores e oferece nova tentativa. */
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        _profileUser ??
        widget.identity ??
        (getIt.isRegistered<ApiClient>()
            ? getIt<ApiClient>().currentUser
            : null);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: FutureBuilder<ProfileOverview>(
          future: _future,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final overview = snapshot.data ?? _visible;
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    key: const PageStorageKey('profile-progress'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
                    children: [
                      const Text(
                        'Seu perfil',
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.brandPurple,
                            child: Text(
                              user?.initials ?? '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Seu perfil',
                                  style: const TextStyle(
                                    color: AppColors.darkTextPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (user != null)
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      color: AppColors.darkTextSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      if (_accountFailed) ...[
                        const Text(
                          'Não foi possível atualizar seus dados.',
                          style: TextStyle(color: AppColors.darkTextSecondary),
                        ),
                        TextButton(
                          onPressed: _loadAccount,
                          child: const Text('Atualizar dados do perfil'),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (snapshot.hasError)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Não foi possível atualizar seu progresso.',
                                style: TextStyle(
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: _refresh,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      if (overview != null) ...[
                        _Panel(
                          title: 'Seu progresso',
                          children: [
                            ProfileProgressBar(
                              value: overview.progress,
                              label: 'Progresso geral',
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _Metric(
                                    icon: Icons.school_outlined,
                                    label: 'Aulas concluídas',
                                    value:
                                        '${overview.completedLessons}/${overview.totalLessons}',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _Metric(
                                    icon: Icons.route_outlined,
                                    label: 'Trilhas concluídas',
                                    value:
                                        '${overview.completedTracks}/${overview.sections.length}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (overview.currentTrack case final current?)
                          _Panel(
                            title: 'Continuar aprendendo',
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const ProfileAnimatedIcon(
                                    icon: Icons.play_circle_outline,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      current.track.title,
                                      style: const TextStyle(
                                        color: AppColors.darkTextPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ProfileProgressBar(
                                value: current.progress.total == 0
                                    ? 0
                                    : current.progress.completed /
                                          current.progress.total,
                                label: 'Trilha atual',
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushReplacementNamed(AppRoute.home.path),
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text('Ir para a trilha'),
                              ),
                            ],
                          ),
                        if (overview.currentTrack != null)
                          const SizedBox(height: 20),
                        _Panel(
                          title: 'Suas trilhas',
                          children: [
                            if (overview.sections.isEmpty)
                              const Text(
                                'Seus treinamentos aparecerão aqui.',
                                style: TextStyle(
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                            for (
                              var index = 0;
                              index < overview.sections.length;
                              index++
                            ) ...[
                              if (index > 0)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(
                                    height: 1,
                                    color: AppColors.darkBorder,
                                  ),
                                ),
                              _TrackProgress(section: overview.sections[index]),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                      ] else if (loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                'Carregando seu progresso…',
                                style: TextStyle(
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      GamificationPanel(
                        repository: _gamificationRepository,
                        memberId: user?.userId,
                        revision: _gamificationRevision,
                      ),
                      const SizedBox(height: 20),
                      _Panel(
                        title: 'Sobre você',
                        children: [
                          _Detail(
                            label: 'Empresa',
                            value: user?.companyName ?? 'Não informada',
                            icon: Icons.business_outlined,
                          ),
                          const SizedBox(height: 12),
                          _Detail(
                            label: 'Cargo',
                            value: user?.jobTitle?.trim().isNotEmpty == true
                                ? user!.jobTitle!
                                : 'Não informado',
                            icon: Icons.badge_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _LogoutButton(),
                    ],
                  ),
                ),
                if (loading || _accountLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LoadingProgressBar(label: 'Atualizando perfil'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value, label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ProfileAnimatedIcon(icon: icon),
      const SizedBox(height: 8),
      Text(
        value,
        style: const TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    ],
  );
}

class _TrackProgress extends StatelessWidget {
  const _TrackProgress({required this.section});
  final TrainingSection section;

  @override
  Widget build(BuildContext context) {
    final progress = section.progress;
    final complete = progress.total > 0 && progress.completed >= progress.total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAnimatedIcon(
              icon: section.locked
                  ? Icons.lock_outline
                  : complete
                  ? Icons.check_circle_outline
                  : Icons.route_outlined,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                section.track.title,
                style: const TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          section.locked
              ? 'Bloqueada'
              : complete
              ? 'Concluída'
              : '${progress.completed} de ${progress.total} aulas concluídas',
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        ProfileProgressBar(
          value: progress.total == 0 ? 0 : progress.completed / progress.total,
          label: 'Avanço na trilha',
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ProfileAnimatedIcon(icon: icon),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 13,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Você poderá entrar novamente quando quiser.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await getIt<ApiClient>().delete('/api/v1/sessoes/atual');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível sair. Tente novamente.'),
          ),
        );
      }
      return;
    }
    getIt<ApiClient>().clearToken();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoute.login.path, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => PressFeedback(
    child: OutlinedButton.icon(
      onPressed: () => _logout(context),
      icon: const Icon(Icons.logout_rounded),
      label: const Text('Sair da conta'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}

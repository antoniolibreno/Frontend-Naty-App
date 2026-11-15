import 'package:flutter/material.dart';
import 'package:natyapp/core/widgets/learning_path_loading.dart';
import 'package:natyapp/theme/app_colors.dart';
import '../../profile/presentation/profile_motion.dart';
import '../data/gamification_repository.dart';
import '../domain/gamification.dart';
import 'streak_flame.dart';
import 'ranking_podium.dart';

class GamificationPanel extends StatefulWidget {
  const GamificationPanel({
    required this.repository,
    required this.memberId,
    this.revision = 0,
    super.key,
  });
  final GamificationRepository? repository;
  final String? memberId;
  final int revision;
  @override
  State<GamificationPanel> createState() => _GamificationPanelState();
}

class _GamificationPanelState extends State<GamificationPanel> {
  Gamification? _data;
  bool _loading = false;
  bool _failed = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(GamificationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.memberId != widget.memberId) _data = null;
    if (oldWidget.memberId != widget.memberId ||
        oldWidget.revision != widget.revision) {
      _load();
    }
  }

  Future<void> _load() async {
    final request = ++_request;
    if (widget.memberId == null || widget.repository == null) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final data = await widget.repository!.fetchSummary(widget.memberId!);
      if (data.memberId != widget.memberId) {
        throw const FormatException('Integrante inesperado');
      }
      if (mounted && request == _request) {
        setState(() {
          _data = data;
        });
      }
    } catch (_) {
      if (mounted && request == _request) {
        setState(() {
          _failed = true;
        });
      }
    } finally {
      if (mounted && request == _request) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _number(double value) => value.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Box(
          title: 'Evolução',
          children: [
            if (_loading)
              const LoadingProgressBar(label: 'Atualizando evolução'),
            if (widget.memberId == null)
              const Text(
                'Entre novamente para carregar sua evolução.',
                style: TextStyle(color: AppColors.darkTextSecondary),
              ),
            if (_failed) ...[
              const Text(
                'Não foi possível atualizar sua evolução.',
                style: TextStyle(color: AppColors.darkTextSecondary),
              ),
              TextButton(
                onPressed: _load,
                child: const Text('Atualizar evolução'),
              ),
            ],
            if (data != null) ...[
              _ValueRow(
                icon: const ProfileAnimatedIcon(icon: Icons.bolt_rounded),
                label: 'XP total',
                value: '${data.totalXp} XP',
              ),
              const SizedBox(height: 12),
              ProfileProgressBar(
                value: data.levelPercent / 100,
                label: 'Nível ${data.level}',
              ),
              const SizedBox(height: 8),
              Text(
                '${data.xpRemaining} XP para o nível ${data.level + 1}',
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              _ValueRow(
                icon: StreakFlame(active: data.currentStreak > 0),
                label: 'Dias seguidos',
                value: '${data.currentStreak}',
              ),
              _ValueRow(
                icon: const ProfileAnimatedIcon(
                  icon: Icons.emoji_events_outlined,
                ),
                label: 'Maior sequência',
                value: '${data.longestStreak} dias',
              ),
              if (data.lastActiveDate case final date?)
                Text(
                  'Último dia ativo: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        _Box(
          title: 'Quizzes',
          children: [
            if (data == null)
              const Text(
                'Suas estatísticas aparecerão aqui.',
                style: TextStyle(color: AppColors.darkTextSecondary),
              )
            else ...[
              if (data.quizzes.attempts == 0)
                const Text(
                  'Você ainda não respondeu nenhum quiz.',
                  style: TextStyle(color: AppColors.darkTextSecondary),
                ),
              _ValueRow(
                icon: const ProfileAnimatedIcon(icon: Icons.quiz_outlined),
                label: 'Tentativas',
                value: '${data.quizzes.attempts}',
              ),
              _ValueRow(
                icon: const ProfileAnimatedIcon(
                  icon: Icons.check_circle_outline,
                ),
                label: 'Aprovações',
                value: '${data.quizzes.approved}',
              ),
              _ValueRow(
                icon: const ProfileAnimatedIcon(icon: Icons.stars_outlined),
                label: 'Melhor nota',
                value: data.quizzes.bestScore == null
                    ? '—'
                    : '${data.quizzes.bestScore}/100',
              ),
              _ValueRow(
                icon: const ProfileAnimatedIcon(icon: Icons.analytics_outlined),
                label: 'Média das notas',
                value: data.quizzes.attempts == 0
                    ? '—'
                    : '${_number(data.quizzes.average)}/100',
              ),
              _ValueRow(
                icon: const ProfileAnimatedIcon(icon: Icons.task_alt_rounded),
                label: 'Acerto geral',
                value: data.quizzes.attempts == 0
                    ? '—'
                    : '${_number(data.quizzes.accuracy)}%',
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        _Box(
          title: 'Conquistas',
          children: [
            if (data == null)
              const Text(
                'Suas conquistas aparecerão aqui.',
                style: TextStyle(color: AppColors.darkTextSecondary),
              )
            else if (data.achievements.isEmpty)
              const Text(
                'Conclua atividades para conquistar seus primeiros marcos.',
                style: TextStyle(color: AppColors.darkTextSecondary),
              )
            else
              for (final achievement in data.achievements)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileAnimatedIcon(
                        icon: _achievementIcon(achievement.code),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.title,
                              style: const TextStyle(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              achievement.description,
                              style: const TextStyle(
                                color: AppColors.darkTextSecondary,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
        const SizedBox(height: 20),
        RankingPodium(
          repository: widget.repository,
          memberId: widget.memberId,
          revision: widget.revision,
        ),
      ],
    );
  }

  IconData _achievementIcon(String code) => switch (code) {
    'PRIMEIRA_ATIVIDADE' => Icons.flag_outlined,
    'PRIMEIRA_TRILHA_CONCLUIDA' => Icons.route_outlined,
    'QUIZ_PERFEITO' => Icons.stars_outlined,
    'TRES_QUIZZES_APROVADOS' => Icons.psychology_outlined,
    'SEQUENCIA_3_DIAS' ||
    'SEQUENCIA_7_DIAS' => Icons.local_fire_department_outlined,
    _ => Icons.workspace_premium_outlined,
  };
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final Widget icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        SizedBox(width: 44, height: 44, child: Center(child: icon)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Box extends StatelessWidget {
  const _Box({required this.title, required this.children});
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

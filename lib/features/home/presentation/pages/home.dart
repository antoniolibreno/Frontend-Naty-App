import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:natyapp/core/components/track_milestone.dart';
import 'package:natyapp/core/widgets/learning_path_loading.dart';
import 'package:natyapp/core/components/learning_path.dart';
import 'package:natyapp/core/di/injection.dart';
import 'package:natyapp/core/router/app_routes.dart';
import 'package:natyapp/features/training/data/training_repository_api.dart';
import 'package:natyapp/features/training/domain/training.dart';
import 'package:natyapp/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.color, super.key});
  final Color color;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<TrainingSection>> _sections;
  Map<String, String> _previousStates = {};
  final Set<String> _pendingCompletions = {};
  List<TrainingSection> _visibleSections = [];
  final Map<String, String?> _pendingTracks = {};
  final Set<String> _celebratingTracks = {};
  final Set<String> _unlockedTracks = {};

  @override
  void initState() {
    super.initState();
    _sections = _load();
  }

  Future<List<TrainingSection>> _load() async {
    final repository = getIt<TrainingRepository>();
    final tracks = await repository.fetchTracks();
    final progress = await Future.wait(
      tracks.map((track) => repository.fetchProgress(track.id)),
    );
    final sections = TrainingSection.sequence(tracks, progress);
    final old = {
      for (final section in _visibleSections) section.track.id: section,
    };
    for (var index = 0; index < sections.length; index++) {
      final section = sections[index];
      final before = old[section.track.id];
      if (before != null &&
          !_complete(before) &&
          _complete(section) &&
          !section.locked) {
        _pendingTracks[section.track.id] =
            index + 1 < sections.length && !sections[index + 1].locked
            ? sections[index + 1].track.id
            : null;
      }
    }
    final current = {
      for (final section in sections)
        for (final activity in section.progress.activities)
          activity.id: activity.state,
    };
    for (final entry in current.entries) {
      if (entry.value == 'CONCLUIDO' &&
          _previousStates.containsKey(entry.key) &&
          _previousStates[entry.key] != 'CONCLUIDO') {
        _pendingCompletions.add(entry.key);
      }
    }
    _previousStates = current;
    _visibleSections = sections;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(_startReadyCelebrations);
    });
    return sections;
  }

  bool _complete(TrainingSection section) =>
      section.progress.total > 0 &&
      section.progress.completed >= section.progress.total;

  void _startReadyCelebrations() {
    for (final section in _visibleSections) {
      if (_pendingTracks.containsKey(section.track.id) &&
          !section.progress.activities.any(
            (activity) => _pendingCompletions.contains(activity.id),
          )) {
        _celebratingTracks.add(section.track.id);
      }
    }
  }

  void _trackAnimationFinished(String trackId) {
    if (!mounted) return;
    setState(() {
      _celebratingTracks.remove(trackId);
      final next = _pendingTracks.remove(trackId);
      if (next != null) _unlockedTracks.add(next);
    });
  }

  void _unlockAnimationFinished(String trackId) {
    if (mounted) {
      setState(() {
        _unlockedTracks.remove(trackId);
      });
    }
  }

  void _animationFinished(String activityId) {
    if (mounted) {
      setState(() {
        _pendingCompletions.remove(activityId);
        _startReadyCelebrations();
      });
    }
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() {
      _sections = next;
    });
    try {
      await next;
    } catch (_) {
      /* A falha é exibida mantendo o percurso. */
    }
  }

  Future<void> _open(
    TrainingSection section,
    TrainingProgressActivity activity,
  ) async {
    if (section.locked || activity.state == 'BLOQUEADO') return;
    await Navigator.of(context).pushNamed(
      AppRoute.aula.path,
      arguments: {
        'activityId': activity.id,
        'trackId': section.track.id,
        'title': activity.title,
        'description': activity.description,
      },
    );
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.darkBackground,
    child: FutureBuilder<List<TrainingSection>>(
      future: _sections,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        if (loading && _visibleSections.isEmpty) {
          return const LearningPathLoading();
        }
        if (snapshot.hasError && _visibleSections.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Não foi possível carregar suas trilhas.'),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _sections = _load();
                    });
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }
        final sections = snapshot.data ?? _visibleSections;
        if (sections.isEmpty) {
          return const Center(child: Text('Nenhuma trilha disponível.'));
        }
        final content = RefreshIndicator(
          onRefresh: _refresh,
          child: LayoutBuilder(
            builder: (context, constraints) => CustomScrollView(
              key: const PageStorageKey('learning-tracks'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                for (var index = 0; index < sections.length; index++)
                  _TrackSection(
                    key: ValueKey(sections[index].track.id),
                    section: sections[index],
                    pendingCompletions: _pendingCompletions,
                    onAnimationEnd: _animationFinished,
                    celebrate: _celebratingTracks.contains(
                      sections[index].track.id,
                    ),
                    highlightUnlock: _unlockedTracks.contains(
                      sections[index].track.id,
                    ),
                    onTrackAnimationEnd: () =>
                        _trackAnimationFinished(sections[index].track.id),
                    onUnlockAnimationEnd: () =>
                        _unlockAnimationFinished(sections[index].track.id),
                    previousTitle: index == 0
                        ? null
                        : sections[index - 1].track.title,
                    onOpen: (activity) => _open(sections[index], activity),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 104 + MediaQuery.paddingOf(context).bottom,
                  ),
                ),
              ],
            ),
          ),
        );
        return Stack(
          children: [
            Positioned.fill(
              child: content.animate().fadeIn(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : 180.ms,
              ),
            ),
            if (loading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LoadingProgressBar(
                  key: const ValueKey('tracks-refreshing'),
                  label: 'Atualizando trilhas',
                ),
              ),
            if (snapshot.hasError)
              Positioned(
                left: 16,
                right: 16,
                bottom: 104,
                child: Material(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Não foi possível atualizar suas trilhas.',
                            style: TextStyle(color: AppColors.darkTextPrimary),
                          ),
                        ),
                        TextButton(
                          onPressed: _refresh,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

class _TrackSection extends StatelessWidget {
  const _TrackSection({
    required this.section,
    required this.previousTitle,
    required this.onOpen,
    required this.pendingCompletions,
    required this.onAnimationEnd,
    required this.celebrate,
    required this.highlightUnlock,
    required this.onTrackAnimationEnd,
    required this.onUnlockAnimationEnd,
    super.key,
  });

  final TrainingSection section;
  final String? previousTitle;
  final ValueChanged<TrainingProgressActivity> onOpen;
  final Set<String> pendingCompletions;
  final ValueChanged<String> onAnimationEnd;
  final bool celebrate, highlightUnlock;
  final VoidCallback onTrackAnimationEnd, onUnlockAnimationEnd;

  @override
  Widget build(BuildContext context) {
    final progress = section.progress;
    final locked = section.locked;
    return SliverMainAxisGroup(
      slivers: [
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final titleStyle = const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w700,
            );
            final statusStyle = TextStyle(
              color: locked
                  ? AppColors.darkTextSecondary
                  : AppColors.brandGreen,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
            );
            final complete =
                progress.total > 0 && progress.completed >= progress.total;
            final status = locked
                ? 'Bloqueada'
                : complete
                ? 'Concluída'
                : '${progress.completed} de ${progress.total} aulas concluídas';
            final instruction = locked
                ? 'Conclua “$previousTitle” para liberar esta trilha.'
                : null;
            final header = _TrackHeader(
              title: section.track.title,
              status: status,
              instruction: instruction,
              locked: locked,
              complete: complete,
              titleStyle: titleStyle,
              statusStyle: statusStyle,
              celebrate: celebrate,
              highlightUnlock: highlightUnlock,
              onAnimationEnd: celebrate
                  ? onTrackAnimationEnd
                  : onUnlockAnimationEnd,
            );
            return PinnedHeaderSliver(child: header);
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: progress.activities.isEmpty
                ? const Center(
                    child: Text(
                      'As aulas desta trilha estarão disponíveis em breve.',
                    ),
                  )
                : LearningPath(
                    stepExtent: 120,
                    nodeSize: 64,
                    physics: const NeverScrollableScrollPhysics(),
                    steps: [
                      for (
                        var index = 0;
                        index < progress.activities.length;
                        index++
                      )
                        LearningPathStep(
                          id: progress.activities[index].id,
                          animateCompletion:
                              !locked &&
                              pendingCompletions.contains(
                                progress.activities[index].id,
                              ),
                          onCompletionAnimationEnd: () =>
                              onAnimationEnd(progress.activities[index].id),
                          label: progress.activities[index].title,
                          state: locked
                              ? LearningPathStepState.locked
                              : _state(progress.activities[index].state),
                          nodeText:
                              locked ||
                                  progress.activities[index].state ==
                                      'BLOQUEADO'
                              ? null
                              : '${index + 1}',
                          horizontalPosition: index.isEven ? .35 : .65,
                          labelSide: index.isEven
                              ? LearningPathLabelSide.right
                              : LearningPathLabelSide.left,
                          onTap:
                              locked ||
                                  progress.activities[index].state ==
                                      'BLOQUEADO'
                              ? null
                              : () => onOpen(progress.activities[index]),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  LearningPathStepState _state(String state) => switch (state) {
    'CONCLUIDO' => LearningPathStepState.completed,
    'DISPONIVEL' => LearningPathStepState.active,
    _ => LearningPathStepState.locked,
  };
}

class _TrackHeader extends StatelessWidget {
  const _TrackHeader({
    required this.title,
    required this.status,
    required this.instruction,
    required this.locked,
    required this.complete,
    required this.titleStyle,
    required this.statusStyle,
    required this.celebrate,
    required this.highlightUnlock,
    required this.onAnimationEnd,
  });
  final String title, status;
  final String? instruction;
  final bool locked, complete;
  final TextStyle titleStyle, statusStyle;
  final bool celebrate, highlightUnlock;
  final VoidCallback onAnimationEnd;
  static const instructionStyle = TextStyle(
    color: AppColors.darkTextSecondary,
    fontSize: 13,
    height: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(
      locked
          ? Icons.lock_outline_rounded
          : complete
          ? Icons.check_circle_outline
          : Icons.route_outlined,
      size: 24,
      color: locked
          ? AppColors.darkTextSecondary
          : complete
          ? AppColors.brandGreen
          : AppColors.brandPurple,
    );
    if (celebrate && !MediaQuery.disableAnimationsOf(context)) {
      icon = icon.animate().scaleXY(
        begin: .7,
        end: 1,
        duration: 450.ms,
        curve: Curves.easeOutCubic,
      );
    }
    final header = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.darkBorder.withValues(alpha: .6)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title, style: titleStyle),
                  ),
                ),
                const SizedBox(width: 12),
                icon,
              ],
            ),
            const SizedBox(height: 6),
            Text(status, style: statusStyle),
            if (instruction != null) ...[
              const SizedBox(height: 6),
              Text(instruction!, style: instructionStyle),
            ],
          ],
        ),
      ),
    );
    return ColoredBox(
      color: AppColors.darkBackground,
      child: celebrate || highlightUnlock
          ? TrackMilestone(
              key: ValueKey(celebrate ? 'completed' : 'unlocked'),
              onComplete: onAnimationEnd,
              child: header,
            )
          : header,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:natyapp/core/widgets/learning_path_loading.dart';
import 'package:natyapp/theme/app_colors.dart';
import '../data/gamification_repository.dart';
import '../domain/gamification.dart';
import 'ranking_view.dart';

class RankingPodium extends StatefulWidget {
  const RankingPodium({
    required this.repository,
    required this.memberId,
    this.revision = 0,
    super.key,
  });
  final GamificationRepository? repository;
  final String? memberId;
  final int revision;
  @override
  State<RankingPodium> createState() => _RankingPodiumState();
}

class _RankingPodiumState extends State<RankingPodium> {
  List<RankingEntry> _items = [];
  bool _loading = false;
  bool _failed = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(RankingPodium oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.memberId != widget.memberId) _items = [];
    if (oldWidget.revision != widget.revision ||
        oldWidget.memberId != widget.memberId) {
      _load();
    }
  }

  Future<void> _load() async {
    final request = ++_request;
    if (widget.repository == null) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final result = await widget.repository!.fetchRanking(page: 0, size: 5);
      if (result.page != 0) throw const FormatException('Página inesperada');
      if (mounted && request == _request) {
        setState(() {
          _items = result.items.take(5).toList()
            ..sort((a, b) => a.position.compareTo(b.position));
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

  void _openRanking() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.darkBackground,
      builder: (_) => FractionallySizedBox(
        heightFactor: .85,
        child: RankingView(
          repository: widget.repository!,
          memberId: widget.memberId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
    decoration: BoxDecoration(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: const Text(
                  'Ranking',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('ranking-options'),
              onPressed: widget.repository == null ? null : _openRanking,
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.darkTextSecondary,
              ),
              tooltip: 'Abrir ranking completo',
            ),
          ],
        ),
        if (_loading) const LoadingProgressBar(label: 'Atualizando pódio'),
        const SizedBox(height: 16),
        if (_items.isNotEmpty)
          RankingPodiumBars(entries: _items, memberId: widget.memberId),
        if (!_loading && !_failed && _items.isEmpty)
          const Text(
            'O pódio aparecerá quando sua equipe começar a aprender.',
            style: TextStyle(color: AppColors.darkTextSecondary, height: 1.5),
          ),
        if (_failed) ...[
          const SizedBox(height: 12),
          const Text(
            'Não foi possível atualizar o pódio.',
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
          TextButton(onPressed: _load, child: const Text('Atualizar pódio')),
        ],
      ],
    ),
  );
}

class RankingPodiumBars extends StatelessWidget {
  const RankingPodiumBars({
    required this.entries,
    required this.memberId,
    super.key,
  });
  final List<RankingEntry> entries;
  final String? memberId;

  @override
  Widget build(BuildContext context) {
    final byPosition = {
      for (final entry in entries.take(5)) entry.position: entry,
    };
    final ordered = [
      for (final position in [4, 2, 1, 3, 5])
        if (byPosition[position] != null) byPosition[position]!,
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var index = 0; index < ordered.length; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(
            child: _PodiumPlace(
              key: ValueKey(
                'podium-${ordered[index].memberId}-${ordered[index].position}',
              ),
              entry: ordered[index],
              isCurrent: ordered[index].memberId == memberId,
              delayIndex: index,
            ),
          ),
        ],
      ],
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.entry,
    required this.isCurrent,
    required this.delayIndex,
    super.key,
  });
  final RankingEntry entry;
  final bool isCurrent;
  final int delayIndex;

  @override
  Widget build(BuildContext context) {
    final height = switch (entry.position) {
      1 => 114.0,
      2 => 92.0,
      3 => 74.0,
      4 => 58.0,
      _ => 44.0,
    };
    final color = switch (entry.position) {
      1 => AppColors.warning,
      2 => AppColors.darkTextSecondary,
      3 => const Color(0xFFC08B60),
      _ => AppColors.brandPurple,
    };
    final name = entry.name.trim().isEmpty ? 'Integrante' : entry.name.trim();
    final initial = String.fromCharCode(name.runes.first).toUpperCase();
    Widget pedestal(double value) => ClipRect(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: value,
          widthFactor: 1,
          alignment: Alignment.bottomCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: .24),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Opacity(
                opacity: value,
                child: Text(
                  '${entry.position}',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final bar = MediaQuery.disableAnimationsOf(context)
        ? pedestal(1)
        : const SizedBox.expand().animate().custom(
            duration: 650.ms,
            delay: Duration(milliseconds: delayIndex * 70),
            curve: Curves.easeOutCubic,
            builder: (_, value, _) => pedestal(value),
          );
    return Semantics(
      container: true,
      label:
          '${entry.position}º lugar, $name, ${entry.totalXp} XP${isCurrent ? ', você' : ''}',
      excludeSemantics: true,
      child: Tooltip(
        message: name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (entry.position == 1)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
            CircleAvatar(
              radius: 16,
              backgroundColor: isCurrent
                  ? AppColors.brandGreen
                  : AppColors.darkSurfaceVariant,
              child: Text(
                initial,
                style: TextStyle(
                  color: isCurrent
                      ? AppColors.darkBackground
                      : AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCurrent ? 'Você' : name.split(RegExp(r'\s+')).first,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 11,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              key: ValueKey('pedestal-${entry.position}'),
              height: height,
              child: bar,
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.totalXp}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'XP',
              style: TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

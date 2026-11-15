import 'package:flutter/material.dart';
import 'package:natyapp/theme/app_colors.dart';
import 'package:natyapp/core/widgets/learning_path_loading.dart';
import '../data/gamification_repository.dart';
import '../domain/gamification.dart';

class RankingView extends StatefulWidget {
  const RankingView({
    required this.repository,
    required this.memberId,
    super.key,
  });
  final GamificationRepository repository;
  final String? memberId;
  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  List<RankingEntry> _items = [];
  RankingPage? _last;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    final page = reset ? 0 : (_last?.page ?? -1) + 1;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.repository.fetchRanking(page: page);
      if (result.page != page) throw const FormatException('Página inesperada');
      if (!mounted) return;
      setState(() {
        _last = result;
        final entries = reset ? result.items : [..._items, ...result.items];
        final ids = <String>{};
        _items = entries.where((entry) => ids.add(entry.memberId)).toList();
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível carregar o ranking.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Ranking da empresa',
                style: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              tooltip: 'Fechar ranking',
            ),
          ],
        ),
      ),
      if (_loading) const LoadingProgressBar(label: 'Carregando ranking'),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () => _load(reset: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (_items.isEmpty && !_loading && _error == null)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'O ranking aparecerá quando sua equipe começar a aprender.',
                    style: TextStyle(color: AppColors.darkTextSecondary),
                  ),
                ),
              for (final item in _items)
                Container(
                  key: ValueKey('ranking-${item.memberId}'),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.memberId == widget.memberId
                        ? AppColors.brandGreen.withValues(alpha: .12)
                        : AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 42,
                        child: Text(
                          '#${item.position}',
                          style: const TextStyle(
                            color: AppColors.brandGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.memberId == widget.memberId
                                  ? '${item.name} · Você'
                                  : item.name,
                              style: const TextStyle(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nível ${item.level} · ${item.currentStreak} dias seguidos',
                              style: const TextStyle(
                                color: AppColors.darkTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${item.totalXp} XP',
                              style: const TextStyle(
                                color: AppColors.brandGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.darkTextSecondary),
                ),
                TextButton(
                  onPressed: () => _load(reset: _last == null),
                  child: const Text('Tentar novamente'),
                ),
              ] else if (!_loading && (_last?.hasMore ?? false))
                TextButton(
                  onPressed: _load,
                  child: const Text('Carregar mais'),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

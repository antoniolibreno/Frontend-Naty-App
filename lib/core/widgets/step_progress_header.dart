import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Topo com botão voltar, barra de progresso em gradiente e contador "1/3".
/// Reutilizável em qualquer fluxo dividido em etapas.
class StepProgressHeader extends StatelessWidget {
  const StepProgressHeader({
    super.key,
    required this.current,
    required this.total,
    this.onBack,
  });

  /// Etapa atual, começando em 1.
  final int current;
  final int total;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;

    return Row(
      children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.maybePop(context),
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.textSecondary,
          tooltip: 'Voltar',
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _GradientProgressBar(value: progress)),
        const SizedBox(width: AppSpacing.md),
        Text('$current/$total', style: AppTextStyles.counter),
      ],
    );
  }
}

class _GradientProgressBar extends StatelessWidget {
  const _GradientProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.pill);

    return Semantics(
      value: '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          height: AppSizes.progressHeight,
          color: AppColors.progressTrack,
          alignment: Alignment.centerLeft,
          // Anima o preenchimento quando avança de pergunta.
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: const LinearGradient(
                    colors: [AppColors.teal, AppColors.purple],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

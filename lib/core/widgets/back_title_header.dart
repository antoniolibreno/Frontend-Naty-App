import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Topo simples com botão voltar e um rótulo ("Trilha 1 de 3").
class BackTitleHeader extends StatelessWidget {
  const BackTitleHeader({super.key, required this.label, this.onBack});

  final String label;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
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
        Text(label, style: AppTextStyles.headerLabel),
      ],
    );
  }
}

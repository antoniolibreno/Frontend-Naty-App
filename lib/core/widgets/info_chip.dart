import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

enum InfoChipVariant { success, neutral }

/// Chip informativo em formato de pílula ("3 trilhas · 28 min").
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    this.variant = InfoChipVariant.neutral,
  });

  final String label;
  final InfoChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      InfoChipVariant.success => (AppColors.chipSuccessBg, AppColors.chipSuccessText),
      InfoChipVariant.neutral => (AppColors.surface, AppColors.textMuted),
    };

    return Container(
      height: AppSizes.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppTextStyles.chip.copyWith(color: fg)),
    );
  }
}

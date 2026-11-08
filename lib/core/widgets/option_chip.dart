import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Opção selecionável do questionário ("Atendente", "1-3"...).
/// Selecionada: borda roxa + fundo roxo escuro. Não selecionada: cinza.
class OptionChip extends StatelessWidget {
  const OptionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  static const _animDuration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.option);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedContainer(
        duration: _animDuration,
        height: AppSizes.optionHeight,
        decoration: BoxDecoration(
          color: selected ? AppColors.optionSelectedBg : AppColors.optionBg,
          borderRadius: radius,
          border: Border.all(
            color: selected
                ? AppColors.optionSelectedBorder
                : AppColors.optionBorder,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                widthFactor: 1, // largura acompanha o texto, não estica
                child: AnimatedDefaultTextStyle(
                  duration: _animDuration,
                  style: AppTextStyles.option.copyWith(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  child: Text(label),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../checklist_models.dart';

/// Card do checklist: checkbox + título + caminho no app ("Canais › Conexões").
/// O card inteiro é clicável, não só o checkbox.
class ChecklistTile extends StatelessWidget {
  const ChecklistTile({
    super.key,
    required this.item,
    required this.marcado,
    required this.onChanged,
  });

  final ChecklistItem item;
  final bool marcado;
  final VoidCallback? onChanged;

  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);

    return Semantics(
      checked: marcado,
      label: item.titulo,
      child: AnimatedContainer(
        duration: _duration,
        decoration: BoxDecoration(
          color: marcado ? AppColors.checkedCardBg : AppColors.optionBg,
          borderRadius: radius,
          border: Border.all(
            color: marcado ? AppColors.checkedCardBorder : AppColors.optionBorder,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onChanged,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CheckBox(marcado: marcado),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.titulo, style: AppTextStyles.itemTitle),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.caminho.join('  ›  '),
                          style: AppTextStyles.itemCaption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.marcado});

  final bool marcado;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: AppSizes.checkbox,
      height: AppSizes.checkbox,
      decoration: BoxDecoration(
        color: marcado ? AppColors.success : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: marcado ? AppColors.success : AppColors.checkboxBorder,
          width: 1.5,
        ),
      ),
      // AnimatedScale dá o "pop" do check ao marcar.
      child: AnimatedScale(
        scale: marcado ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: const Icon(
          Icons.check_rounded,
          size: 16,
          color: AppColors.textOnBrand,
        ),
      ),
    );
  }
}

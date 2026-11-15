import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/quiz_option.dart';

class QuizOptionCard extends StatelessWidget {
  const QuizOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.confirmed,
    required this.correct,
    required this.onTap,
  });
  final QuizOption option;
  final bool selected, confirmed;
  final bool? correct;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final color = confirmed && correct == true
        ? AppColors.success
        : confirmed && selected && correct == false
        ? AppColors.error
        : selected
        ? AppColors.purple
        : AppColors.optionBorder;
    return Semantics(
      button: true,
      selected: selected,
      label: option.text,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: .12) : AppColors.surface,
            border: Border.all(
              color: color,
              width: selected || (confirmed && correct == true) ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              Expanded(child: Text(option.text, style: AppTextStyles.question)),
              if (confirmed && correct == true)
                const Icon(Icons.check_circle, color: AppColors.success),
            ],
          ),
        ),
      ),
    );
  }
}

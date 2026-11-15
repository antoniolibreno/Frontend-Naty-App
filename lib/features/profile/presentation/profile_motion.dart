import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:natyapp/theme/app_colors.dart';

class ProfileProgressBar extends StatelessWidget {
  const ProfileProgressBar({
    required this.value,
    required this.label,
    super.key,
  });
  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0.0, 1.0);
    Widget bar(double fill) => ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: fill,
        minHeight: 8,
        color: AppColors.brandGreen,
        backgroundColor: AppColors.darkBorder,
      ),
    );
    final animated = MediaQuery.disableAnimationsOf(context)
        ? bar(progress)
        : const SizedBox(height: 8)
              .animate(target: progress)
              .custom(
                duration: 700.ms,
                curve: Curves.linear,
                builder: (_, fill, _) => bar(fill),
              );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                color: AppColors.brandGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Semantics(
          label: label,
          value: '${(progress * 100).round()}%',
          child: ExcludeSemantics(child: animated),
        ),
      ],
    );
  }
}

class ProfileAnimatedIcon extends StatelessWidget {
  const ProfileAnimatedIcon({required this.icon, super.key});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final child = Icon(icon, color: AppColors.brandGreen, size: 24);
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return child
        .animate()
        .scaleXY(
          begin: .85,
          end: 1,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .rotate(
          begin: -.04,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:natyapp/theme/app_colors.dart';

/// Destaque finito, exibido após a onda da última aula ou ao liberar a próxima.
class TrackMilestone extends StatelessWidget {
  const TrackMilestone({
    required this.child,
    required this.onComplete,
    super.key,
  });
  final Widget child;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());
      return child;
    }
    return child
        .animate(onComplete: (_) => onComplete())
        .custom(
          duration: 650.ms,
          builder: (context, value, child) => DecoratedBox(
            decoration: BoxDecoration(
              color: Color.lerp(
                AppColors.darkBackground,
                AppColors.brandGreen.withValues(alpha: .16),
                math.sin(value * math.pi),
              ),
            ),
            child: child,
          ),
        );
  }
}

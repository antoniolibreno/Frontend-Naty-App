import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:natyapp/theme/app_colors.dart';

/// Celebra uma conclusão confirmada pela API, sem animação contínua em repouso.
class CompletionWaterFill extends StatelessWidget {
  const CompletionWaterFill({required this.size, this.onComplete, super.key});

  final double size;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      if (onComplete != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onComplete?.call());
      }
      return SizedBox.square(
        dimension: size,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.brandGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: AppColors.darkBackground),
        ),
      );
    }
    return RepaintBoundary(
      child: SizedBox.square(dimension: size)
          .animate(onComplete: (_) => onComplete?.call())
          .custom(
            duration: 1200.ms,
            curve: Curves.linear,
            builder: (context, value, child) {
              return SizedBox.square(
                dimension: size,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipOval(
                      child: CustomPaint(
                        painter: CompletionWaterPainter(value),
                      ),
                    ),
                    Opacity(
                      opacity: ((value - .7) / .3).clamp(0.0, 1.0),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.darkBackground,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              );
            },
          )
          .scaleXY(
            begin: 1,
            end: 1.08,
            delay: 1200.ms,
            duration: 120.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scaleXY(
            begin: 1,
            end: 1 / 1.08,
            duration: 180.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class CompletionWaterPainter extends CustomPainter {
  const CompletionWaterPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.brandPurple);
    for (var layer = 0; layer < 2; layer++) {
      final path = Path()..moveTo(0, size.height);
      final amplitude = math.sin(progress * math.pi) * size.height * .065;
      final level = size.height * (1 - progress);
      for (var x = 0.0; x <= size.width; x += 1) {
        final y =
            level +
            math.sin(
                  x / size.width * math.pi * 2 +
                      progress * math.pi * 4 +
                      layer * 1.8,
                ) *
                amplitude;
        path.lineTo(x, y - (layer == 0 ? amplitude * .5 : 0));
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = layer == 0
              ? AppColors.brandGreen.withValues(alpha: .45)
              : AppColors.brandGreen,
      );
    }
  }

  @override
  bool shouldRepaint(CompletionWaterPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

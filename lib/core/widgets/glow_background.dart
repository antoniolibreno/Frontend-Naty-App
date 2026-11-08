import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fundo escuro com os dois brilhos difusos do Figma:
/// verde-água à esquerda e roxo no canto superior direito.
class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(
        children: [
          const _Glow(
            alignment: Alignment(1.1, -1.0),
            color: AppColors.glowPurple,
            radiusFactor: 0.9,
          ),
          const _Glow(
            alignment: Alignment(-1.2, -0.55),
            color: AppColors.glowTeal,
            radiusFactor: 0.7,
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.alignment,
    required this.color,
    required this.radiusFactor,
  });

  final Alignment alignment;
  final Color color;

  /// Raio relativo à largura da tela.
  final double radiusFactor;

  @override
  Widget build(BuildContext context) {
    // IgnorePointer: o brilho é decorativo e não deve capturar toques.
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: alignment,
              radius: radiusFactor,
              colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}

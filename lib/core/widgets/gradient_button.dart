import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Botão principal.
/// - Habilitado: gradiente da marca com texto escuro.
/// - Desabilitado (onPressed == null): fundo cinza com texto apagado,
///   como o "Confirmar resposta" do Figma.
/// - Loading: spinner no lugar do texto.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  bool get _disabled => onPressed == null;
  bool get _tappable => !_disabled && !isLoading;

  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.button);

    return Semantics(
      button: true,
      enabled: _tappable,
      label: label,
      child: AnimatedContainer(
        duration: _duration,
        decoration: BoxDecoration(
          color: _disabled ? AppColors.buttonDisabledBg : null,
          gradient: _disabled ? null : AppColors.brandGradient,
          borderRadius: radius,
        ),
        // Material transparente para o efeito de toque (ripple) aparecer
        // por cima do gradiente.
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: _tappable ? onPressed : null,
            child: SizedBox(
              height: AppSizes.buttonHeight,
              width: double.infinity,
              child: Center(
                child: isLoading
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.textOnBrand,
                        ),
                      )
                    : AnimatedDefaultTextStyle(
                        duration: _duration,
                        style: AppTextStyles.button.copyWith(
                          color: _disabled
                              ? AppColors.buttonDisabledText
                              : AppColors.textOnBrand,
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

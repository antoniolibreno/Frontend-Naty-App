import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../quiz_models.dart';

/// Card de alternativa: badge com a letra (A, B, C...) + texto.
/// As cores mudam conforme o [estado] (selecionada, correta, incorreta...).
class AnswerOptionCard extends StatelessWidget {
  const AnswerOptionCard({
    super.key,
    required this.letra,
    required this.texto,
    required this.estado,
    required this.onTap,
  });

  final String letra;
  final String texto;
  final AlternativaEstado estado;
  final VoidCallback? onTap;

  static const _duration = Duration(milliseconds: 200);

  ({Color bg, Color border, Color badgeBg, Color badgeText}) get _cores =>
      switch (estado) {
        AlternativaEstado.normal || AlternativaEstado.apagada => (
            bg: AppColors.optionBg,
            border: AppColors.optionBorder,
            badgeBg: AppColors.letterBadgeBg,
            badgeText: AppColors.textSecondary,
          ),
        AlternativaEstado.selecionada => (
            bg: AppColors.optionSelectedBg,
            border: AppColors.optionSelectedBorder,
            badgeBg: AppColors.purple,
            badgeText: AppColors.textPrimary,
          ),
        AlternativaEstado.correta => (
            bg: AppColors.successBg,
            border: AppColors.success,
            badgeBg: AppColors.success,
            badgeText: AppColors.textOnBrand,
          ),
        AlternativaEstado.incorreta => (
            bg: AppColors.errorBg,
            border: AppColors.error,
            badgeBg: AppColors.error,
            badgeText: AppColors.textOnBrand,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final c = _cores;
    final radius = BorderRadius.circular(AppRadius.card);

    return Semantics(
      button: true,
      selected: estado == AlternativaEstado.selecionada,
      label: 'Alternativa $letra: $texto',
      child: AnimatedOpacity(
        duration: _duration,
        // Depois de confirmar, as alternativas irrelevantes ficam apagadas.
        opacity: estado == AlternativaEstado.apagada ? 0.5 : 1,
        child: AnimatedContainer(
          duration: _duration,
          constraints: const BoxConstraints(minHeight: AppSizes.answerMinHeight),
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: radius,
            border: Border.all(color: c.border),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    _LetterBadge(letra: letra, bg: c.badgeBg, fg: c.badgeText, estado: estado),
                    const SizedBox(width: 13),
                    // Expanded: textos longos quebram linha sem estourar.
                    Expanded(child: Text(texto, style: AppTextStyles.answer)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LetterBadge extends StatelessWidget {
  const _LetterBadge({
    required this.letra,
    required this.bg,
    required this.fg,
    required this.estado,
  });

  final String letra;
  final Color bg;
  final Color fg;
  final AlternativaEstado estado;

  @override
  Widget build(BuildContext context) {
    // Na correção, a letra vira ícone de certo/errado.
    final icon = switch (estado) {
      AlternativaEstado.correta => Icons.check_rounded,
      AlternativaEstado.incorreta => Icons.close_rounded,
      _ => null,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: AppSizes.letterBadge,
      height: AppSizes.letterBadge,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 16, color: fg)
          : Text(letra, style: AppTextStyles.letter.copyWith(color: fg)),
    );
  }
}

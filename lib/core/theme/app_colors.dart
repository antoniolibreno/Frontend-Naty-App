import 'package:flutter/material.dart';

/// Paleta do NatyApp, estimada a partir dos prints do Figma.
/// Quando o grupo tiver os hex oficiais, basta ajustar aqui.
abstract final class AppColors {
  // Fundo
  static const background = Color(0xFF0B0F17);
  static const surface = Color(0xFF1A1F29);

  // Marca (gradiente verde-água → roxo)
  static const teal = Color(0xFF26C6A2);
  static const purple = Color(0xFF5B4FE9);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, purple],
  );

  // Brilhos difusos do fundo
  static const glowTeal = Color(0xFF14594A);
  static const glowPurple = Color(0xFF2E2878);

  // Texto
  static const textPrimary = Color(0xFFEEF1F6);
  static const textSecondary = Color(0xFF9AA3B2);
  static const textMuted = Color(0xFFA4ABB8);
  static const textOnBrand = Color(0xFF0B0F17);

  // Chips
  static const chipSuccessBg = Color(0xFF0F2A27);
  static const chipSuccessText = Color(0xFF3DD9A6);

  // Opções selecionáveis (questionário)
  static const optionBg = Color(0xFF141821);
  static const optionBorder = Color(0xFF242A36);
  static const optionSelectedBg = Color(0xFF16173F);
  static const optionSelectedBorder = Color(0xFF5B4FE9);

  // Rótulo de etapa ("PASSO 0 DE 3")
  static const stepLabel = Color(0xFF5B4FE9);

  static const error = Color(0xFFFF6B6B);

  // Botão desabilitado
  static const buttonDisabledBg = Color(0xFF161B24);
  static const buttonDisabledText = Color(0xFF5F6878);

  // Barra de progresso
  static const progressTrack = Color(0xFF1C212B);

  // Quiz: badge da letra e feedback de resposta
  static const letterBadgeBg = Color(0xFF1F2430);
  static const success = Color(0xFF26C6A2);
  static const successBg = Color(0xFF0E2A25);
  static const errorBg = Color(0xFF2E1519);

  // Checklist
  static const checkedCardBg = Color(0xFF0D1D21);
  static const checkedCardBorder = Color(0xFF1C5248);
  static const checkboxBorder = Color(0xFF3A4150);
}

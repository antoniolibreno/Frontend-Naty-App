import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Estilos de texto do app. A fonte do Figma se parece com a Manrope;
/// confirme com o grupo e troque aqui se for outra.
abstract final class AppTextStyles {
  static TextStyle get display => GoogleFonts.manrope(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.12,
        letterSpacing: -0.8,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get chip => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get button => GoogleFonts.manrope(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textOnBrand,
      );

  static TextStyle get title => GoogleFonts.manrope(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get stepLabel => GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: AppColors.stepLabel,
      );

  static TextStyle get subtitle => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  static TextStyle get question => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get option => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get answer => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: AppColors.textPrimary,
      );

  static TextStyle get letter => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get counter => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: AppColors.textSecondary,
      );

  static TextStyle get headerLabel => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  static TextStyle get itemTitle => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get itemCaption => GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get link => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      );
}

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purple,
          secondary: AppColors.teal,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
      );
}

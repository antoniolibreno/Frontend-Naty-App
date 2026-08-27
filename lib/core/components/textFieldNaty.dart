import 'package:flutter/material.dart';

/// Campo de texto padrão da NatyApp.
///
/// O componente usa os tokens do [ColorScheme] configurado pela aplicação,
/// portanto acompanha automaticamente os temas claro e escuro.
class TextFieldNaty extends StatelessWidget {
  const TextFieldNaty({
    required this.onChanged,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(12);

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: obscureText ? 1 : maxLines,
      style: TextStyle(color: colors.onSurface, fontSize: 16, height: 1.5),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        constraints: const BoxConstraints(minHeight: 56),
        labelStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
        floatingLabelStyle: TextStyle(
          color: colors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
        prefixIconColor: colors.onSurfaceVariant,
        suffixIconColor: colors.onSurfaceVariant,
        border: _border(colors.outline, radius),
        enabledBorder: _border(colors.outline, radius),
        focusedBorder: _border(colors.primary, radius, width: 2),
        errorBorder: _border(colors.error, radius),
        focusedErrorBorder: _border(colors.error, radius, width: 2),
        disabledBorder: _border(colors.outline.withValues(alpha: 0.5), radius),
        errorStyle: TextStyle(color: colors.error, fontSize: 14, height: 1.4),
        helperStyle: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  OutlineInputBorder _border(
    Color color,
    BorderRadius radius, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

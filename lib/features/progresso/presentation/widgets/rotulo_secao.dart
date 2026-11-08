import 'package:flutter/material.dart';
import 'package:natyapp/theme/app_colors.dart';

/// Título pequeno em caixa alta que abre uma seção (ex.: "CONQUISTAS").
class RotuloSecao extends StatelessWidget {
  const RotuloSecao(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          color: AppColors.darkTextDisabled,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

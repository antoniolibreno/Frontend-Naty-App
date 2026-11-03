import 'package:flutter/material.dart';
import 'package:natyapp/theme/app_colors.dart';

class CarregandoConteudo extends StatelessWidget {
  const CarregandoConteudo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.brandGreen),
    );
  }
}

class FalhaCarregamento extends StatelessWidget {
  const FalhaCarregamento({
    required this.mensagem,
    required this.onTentarNovamente,
    super.key,
  });

  final String mensagem;
  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            TextButton(
              onPressed: onTentarNovamente,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandGreen,
              ),
              child: const Text(
                'Tentar novamente',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

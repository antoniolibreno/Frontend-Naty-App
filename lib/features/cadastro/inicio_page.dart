import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glow_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/info_chip.dart';
import 'cadastro_strings.dart';

/// Tela 1 da jornada de cadastro: boas-vindas.
///
/// A navegação fica por conta de quem usa a tela (callbacks), assim ela
/// não depende do gerenciador de estado/rotas que o grupo escolher.
class InicioPage extends StatelessWidget {
  const InicioPage({
    super.key,
    required this.onComecar,
    required this.onJaTenhoConta,
    this.isLoading = false,
  });

  final VoidCallback onComecar;
  final VoidCallback onJaTenhoConta;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            // LayoutBuilder + scroll: em telas pequenas (ou fonte grande de
            // acessibilidade) o conteúdo rola em vez de estourar; em telas
            // normais o botão fica preso no rodapé como no Figma.
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 64),
                        const _BrandLogo(),
                        const SizedBox(height: AppSpacing.lg),
                        const _Header(),
                        const SizedBox(height: AppSpacing.lg),
                        const _InfoChips(),
                        const Spacer(),
                        GradientButton(
                          label: InicioStrings.botaoComecar,
                          isLoading: isLoading,
                          onPressed: onComecar,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Center(
                          child: TextButton(
                            onPressed: isLoading ? null : onJaTenhoConta,
                            child: Text(
                              InicioStrings.linkJaTenhoConta,
                              style: AppTextStyles.link,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Círculo com o gradiente da marca. Substituir por Image.asset quando
/// o logo oficial estiver disponível.
class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.logo,
      height: AppSizes.logo,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brandGradient,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(InicioStrings.titulo, style: AppTextStyles.display),
        const SizedBox(height: AppSpacing.md),
        Text(InicioStrings.subtitulo, style: AppTextStyles.body),
      ],
    );
  }
}

class _InfoChips extends StatelessWidget {
  const _InfoChips();

  @override
  Widget build(BuildContext context) {
    // Wrap quebra a linha se os chips não couberem lado a lado.
    return const Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        InfoChip(
          label: InicioStrings.chipTrilhas,
          variant: InfoChipVariant.success,
        ),
        InfoChip(label: InicioStrings.chipCertificado),
      ],
    );
  }
}

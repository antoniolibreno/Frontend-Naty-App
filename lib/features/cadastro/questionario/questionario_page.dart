import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/option_chip.dart';
import '../cadastro_strings.dart';
import 'questionario_controller.dart';
import 'questionario_models.dart';

/// Tela 2 da jornada de cadastro: questionário "Antes de começar".
class QuestionarioPage extends StatefulWidget {
  const QuestionarioPage({
    super.key,
    required this.enviar,
    required this.onConcluido,
  });

  /// Envia as respostas para onde o grupo definir (API/Firebase).
  final EnviarRespostas enviar;

  /// Chamado após o envio dar certo, normalmente navega para a próxima tela.
  final ValueChanged<QuestionarioRespostas> onConcluido;

  @override
  State<QuestionarioPage> createState() => _QuestionarioPageState();
}

class _QuestionarioPageState extends State<QuestionarioPage> {
  late final QuestionarioController _controller =
      QuestionarioController(enviar: widget.enviar);

  @override
  void dispose() {
    _controller.dispose(); // evita memory leak
    super.dispose();
  }

  Future<void> _montarTrilha() async {
    final respostas = await _controller.enviar();
    if (!mounted) return;

    if (respostas != null) {
      widget.onConcluido(respostas);
    } else if (_controller.erro != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(_controller.erro!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // ListenableBuilder reconstrói só quando o controller notifica.
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.formHorizontal,
                    AppSpacing.lg,
                    AppSpacing.formHorizontal,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Header(),
                      const SizedBox(height: AppSpacing.xl),
                      _Pergunta<PapelAtendimento>(
                        titulo: QuestionarioStrings.perguntaPapel,
                        opcoes: PapelAtendimento.values,
                        label: (o) => o.label,
                        selecionada: _controller.papel,
                        onSelecionar: _controller.selecionarPapel,
                      ),
                      const SizedBox(height: AppSpacing.lg + AppSpacing.xs),
                      _Pergunta<UsoWhatsApp>(
                        titulo: QuestionarioStrings.perguntaWhatsApp,
                        opcoes: UsoWhatsApp.values,
                        label: (o) => o.label,
                        selecionada: _controller.whatsApp,
                        onSelecionar: _controller.selecionarWhatsApp,
                      ),
                      const SizedBox(height: AppSpacing.lg + AppSpacing.xs),
                      _Pergunta<TamanhoEquipe>(
                        titulo: QuestionarioStrings.perguntaEquipe,
                        opcoes: TamanhoEquipe.values,
                        label: (o) => o.label,
                        selecionada: _controller.tamanhoEquipe,
                        onSelecionar: _controller.selecionarTamanho,
                      ),
                    ],
                  ),
                ),
              ),
              // Rodapé fixo, fora do scroll, como no Figma.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.formHorizontal,
                  AppSpacing.sm,
                  AppSpacing.formHorizontal,
                  AppSpacing.md,
                ),
                child: GradientButton(
                  label: QuestionarioStrings.botaoMontar,
                  isLoading: _controller.enviando,
                  // null = desabilitado até as 3 perguntas serem respondidas
                  onPressed: _controller.completo ? _montarTrilha : null,
                ),
              ),
            ],
          ),
        ),
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
        Text(QuestionarioStrings.passo, style: AppTextStyles.stepLabel),
        const SizedBox(height: AppSpacing.md),
        Text(QuestionarioStrings.titulo, style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
        Text(QuestionarioStrings.subtitulo, style: AppTextStyles.subtitle),
      ],
    );
  }
}

/// Pergunta de escolha única. Genérica para servir aos três enums.
class _Pergunta<T> extends StatelessWidget {
  const _Pergunta({
    super.key,
    required this.titulo,
    required this.opcoes,
    required this.label,
    required this.selecionada,
    required this.onSelecionar,
  });

  final String titulo;
  final List<T> opcoes;
  final String Function(T) label;
  final T? selecionada;
  final ValueChanged<T> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: titulo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppTextStyles.question),
          const SizedBox(height: AppSpacing.md),
          // Wrap faz "Ainda não" descer para a linha de baixo, como no Figma.
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm + AppSpacing.xs,
            children: [
              for (final opcao in opcoes)
                OptionChip(
                  label: label(opcao),
                  selected: opcao == selecionada,
                  onTap: () => onSelecionar(opcao),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

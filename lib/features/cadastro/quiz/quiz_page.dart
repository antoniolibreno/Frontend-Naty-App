import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/step_progress_header.dart';
import '../cadastro_strings.dart';
import 'quiz_controller.dart';
import 'quiz_models.dart';
import 'widgets/answer_option_card.dart';

/// Tela 3 da jornada de cadastro: quiz de múltipla escolha.
class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    required this.perguntas,
    required this.onConcluido,
  });

  final List<QuizPergunta> perguntas;
  final ValueChanged<QuizResultado> onConcluido;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final QuizController _controller = QuizController(widget.perguntas);

  static const _letras = 'ABCDEFGH';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBotao() {
    if (!_controller.confirmada) {
      _controller.confirmar();
      return;
    }
    final resultado = _controller.avancar();
    if (resultado != null) widget.onConcluido(resultado);
  }

  String get _labelBotao {
    if (!_controller.confirmada) return QuizStrings.confirmar;
    return _controller.ultima ? QuizStrings.finalizar : QuizStrings.continuar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _controller.vazio
            ? const _EstadoVazio()
            : ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  final p = _controller.atual;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.formHorizontal,
                          0,
                        ),
                        child: StepProgressHeader(
                          current: _controller.indice + 1,
                          total: _controller.total,
                        ),
                      ),
                      Expanded(
                        // AnimatedSwitcher: transição suave entre perguntas.
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: SingleChildScrollView(
                            key: ValueKey(_controller.indice),
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.formHorizontal,
                              AppSpacing.lg + AppSpacing.xs,
                              AppSpacing.formHorizontal,
                              AppSpacing.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${QuizStrings.prefixoCategoria} · ${p.categoria}'
                                      .toUpperCase(),
                                  style: AppTextStyles.stepLabel,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(p.enunciado, style: AppTextStyles.title),
                                const SizedBox(height: AppSpacing.lg),
                                for (var i = 0; i < p.alternativas.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: AnswerOptionCard(
                                      letra: _letras[i],
                                      texto: p.alternativas[i],
                                      estado: _controller.estadoDe(i),
                                      onTap: _controller.confirmada
                                          ? null
                                          : () => _controller.selecionar(i),
                                    ),
                                  ),
                                if (_controller.confirmada)
                                  _Feedback(acertou: _controller.acertou),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.formHorizontal,
                          AppSpacing.sm,
                          AppSpacing.formHorizontal,
                          AppSpacing.md,
                        ),
                        child: GradientButton(
                          label: _labelBotao,
                          // Desabilitado (cinza) até escolher uma alternativa.
                          onPressed:
                              _controller.selecionada == null ? null : _onBotao,
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

/// Mensagem curta após confirmar a resposta.
class _Feedback extends StatelessWidget {
  const _Feedback({required this.acertou});

  final bool acertou;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            acertou ? Icons.check_circle_rounded : Icons.info_rounded,
            size: 18,
            color: acertou ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            acertou ? QuizStrings.feedbackCerto : QuizStrings.feedbackErrado,
            style: AppTextStyles.question.copyWith(
              color: acertou ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.quiz_outlined, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              QuizStrings.vazio,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => Navigator.maybePop(context),
              child: Text(QuizStrings.voltar, style: AppTextStyles.link),
            ),
          ],
        ),
      ),
    );
  }
}

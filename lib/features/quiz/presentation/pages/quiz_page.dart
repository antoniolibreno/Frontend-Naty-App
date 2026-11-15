import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/step_progress_header.dart';
import '../../domain/quiz.dart';
import '../../domain/quiz_result.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import '../widgets/quiz_option_card.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key, required this.contexto, this.onCompleted});
  final QuizContext contexto;
  final ValueChanged<QuizResult>? onCompleted;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<QuizBloc>()..add(QuizStarted(contexto)),
    child: _QuizView(contexto: contexto, onCompleted: onCompleted),
  );
}

class _QuizView extends StatelessWidget {
  const _QuizView({required this.contexto, this.onCompleted});
  final QuizContext contexto;
  final ValueChanged<QuizResult>? onCompleted;
  @override
  Widget build(BuildContext context) => BlocListener<QuizBloc, QuizState>(
    listener: (context, state) {
      if (state is QuizCompleted) onCompleted?.call(state.result);
    },
    child: BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
        if (state is QuizLoading || state is QuizInitial)
          return const Center(child: CircularProgressIndicator());
        if (state is QuizFailure)
          return _Failure(
            message: state.message,
            retry: () => context.read<QuizBloc>().add(QuizStarted(contexto)),
          );
        if (state is QuizSubmitting)
          return const Center(child: CircularProgressIndicator());
        if (state is QuizCompleted) return _Completed(result: state.result);
        final current = state as QuizReady;
        if (current.quiz.questions.isEmpty) {
          return const _Failure(
            message: 'Nenhuma pergunta disponível para este quiz.',
            retry: _noop,
          );
        }
        final question = current.quiz.questions[current.currentIndex];
        final confirmed = current.confirmed.contains(question.id);
        final selected = current.answers[question.id];
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.formHorizontal,
                    0,
                  ),
                  child: StepProgressHeader(
                    current: current.currentIndex + 1,
                    total: current.quiz.questions.length,
                    onBack: current.currentIndex == 0
                        ? null
                        : () => context.read<QuizBloc>().add(
                            const QuizPreviousRequested(),
                          ),
                  ),
                ),
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
                        Text('QUIZ', style: AppTextStyles.stepLabel),
                        const SizedBox(height: AppSpacing.md),
                        Text(question.statement, style: AppTextStyles.title),
                        const SizedBox(height: AppSpacing.lg),
                        for (final option in question.options)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: QuizOptionCard(
                              option: option,
                              selected: selected == option.id,
                              confirmed: confirmed,
                              correct: null,
                              onTap: confirmed
                                  ? null
                                  : () => context.read<QuizBloc>().add(
                                      QuizAnswerSelected(
                                        question.id,
                                        option.id,
                                      ),
                                    ),
                            ),
                          ),
                      ],
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
                    label: confirmed
                        ? (current.currentIndex ==
                                  current.quiz.questions.length - 1
                              ? 'Finalizar'
                              : 'Continuar')
                        : 'Confirmar resposta',
                    onPressed: selected == null
                        ? null
                        : () => context.read<QuizBloc>().add(
                            const QuizNextRequested(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

void _noop() {}

class _Failure extends StatelessWidget {
  const _Failure({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 40),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        TextButton(onPressed: retry, child: const Text('Tentar novamente')),
      ],
    ),
  );
}

class _Completed extends StatelessWidget {
  const _Completed({required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final nota = result.grade ?? (result.percentage * 100).round();
    final aprovado = result.approved ?? false;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.formHorizontal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  aprovado ? Icons.check_circle : Icons.refresh_rounded,
                  color: aprovado ? AppColors.success : AppColors.purple,
                  size: 64,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  aprovado ? 'Quiz aprovado!' : 'Você pode tentar novamente',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Nota: $nota/100', style: AppTextStyles.subtitle),
                if (!aprovado && result.wrongQuestionIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      '${result.wrongQuestionIds.length} questão(ões) para revisar.',
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                GradientButton(
                  label: 'Voltar para a trilha',
                  onPressed: () => Navigator.of(context).popUntil(
                    (route) =>
                        route.settings.name == AppRoute.home.path ||
                        route.isFirst,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

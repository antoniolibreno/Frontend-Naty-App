import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../quiz/domain/quiz.dart';
import '../../../quiz/domain/quiz_result.dart';
import '../../../quiz/presentation/pages/quiz_page.dart';
import '../bloc/nivelamento_bloc.dart';

class NivelamentoPage extends StatelessWidget {
  const NivelamentoPage({super.key, required this.onConcluido});
  final ValueChanged<NivelamentoCompleted> onConcluido;
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<NivelamentoBloc>(),
        child: Builder(
          // Este contexto já está abaixo do BlocProvider. Sem o Builder, o
          // resultado era calculado fora do provider e a navegação não era
          // disparada após a tela chegar em 3/3.
          builder: (blocContext) => QuizPage(
            contexto: const QuizContext(
              trilhaId: 'trilha-1',
              quizId: 'nivelamento-inicial',
            ),
            onCompleted: (result) => _calcular(blocContext, result),
          ),
        ),
      );
  void _calcular(BuildContext context, QuizResult result) {
    final bloc = context.read<NivelamentoBloc>();
    bloc.add(NivelamentoResultRequested(result));
    bloc.stream.firstWhere((state) => state is NivelamentoCompleted).then((state) {
      if (context.mounted) onConcluido(state as NivelamentoCompleted);
    });
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'checklist/checklist_mock.dart';
import 'checklist/checklist_page.dart';
import 'inicio_page.dart';
import 'questionario/questionario_page.dart';
import 'quiz/quiz_mock.dart';
import 'quiz/quiz_page.dart';

/// Fluxo de cadastro: Início → Questionário → Quiz → Checklist.
///
/// Usa um Navigator próprio para que o tema escuro do cadastro valha para
/// todas as telas do fluxo sem alterar o tema do restante do app.
class CadastroFlow extends StatelessWidget {
  const CadastroFlow({super.key, this.onJaTenhoConta});

  /// Chamado ao tocar em "Já tenho conta" na tela de início.
  final VoidCallback? onJaTenhoConta;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (context) => InicioPage(
            onComecar: () => _abrirQuestionario(context),
            onJaTenhoConta: onJaTenhoConta ?? () {},
          ),
        ),
      ),
    );
  }

  void _abrirQuestionario(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuestionarioPage(
          // TODO: trocar pelo envio real (API/Firebase) quando definido.
          enviar: (respostas) async {
            await Future<void>.delayed(const Duration(seconds: 1));
            debugPrint('Respostas: ${respostas.toJson()}');
          },
          onConcluido: (_) => _abrirQuiz(context),
        ),
      ),
    );
  }

  void _abrirQuiz(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizPage(
          perguntas: quizCanaisMock,
          onConcluido: (r) {
            debugPrint('Quiz: ${r.acertos}/${r.total}');
            _abrirChecklist(context);
          },
        ),
      ),
    );
  }

  void _abrirChecklist(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChecklistPage(
          trilha: trilha1ChecklistMock,
          // TODO: trocar pelo salvamento real (API/Firebase).
          salvar: (ids) async {
            await Future<void>.delayed(const Duration(seconds: 1));
            debugPrint('Checklist marcado: $ids');
          },
          // Fim da jornada de cadastro: volta ao início por enquanto.
          // TODO: levar para a tela de Jornada/Progresso.
          onConcluido: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
    );
  }
}

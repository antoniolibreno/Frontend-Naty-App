import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/checklist_mock.dart';
import 'pages/checklist_page.dart';
import 'pages/inicio_page.dart';
import 'pages/questionario_page.dart';

/// Fluxo legado de onboarding. Contas reais são criadas pelo painel; o fluxo
/// permanece somente para compatibilidade com telas antigas e não é exposto no
/// login.
///
/// Usa um Navigator próprio para que o tema escuro do cadastro valha para
/// todas as telas do fluxo sem alterar o tema do restante do app.
class CadastroFlow extends StatelessWidget {
  const CadastroFlow({super.key, this.onJaTenhoConta, this.onConcluido});

  /// Chamado ao tocar em "Já tenho conta" na tela de início.
  final VoidCallback? onJaTenhoConta;

  /// Chamado ao concluir o checklist, normalmente para abrir a Home.
  final VoidCallback? onConcluido;

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
          onConcluido: (_) => _abrirChecklist(context),
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
          onConcluido:
              onConcluido ??
              () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
    );
  }
}

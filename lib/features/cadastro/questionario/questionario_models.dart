/// Respostas do questionário inicial. Enums em vez de strings soltas,
/// assim o backend recebe valores estáveis (`name`) e a UI mostra `label`.

enum PapelAtendimento {
  atendente('Atendente'),
  supervisor('Supervisor'),
  gestor('Gestor');

  const PapelAtendimento(this.label);
  final String label;
}

enum UsoWhatsApp {
  apiOficial('Sim, API oficial'),
  appComum('Sim, app comum'),
  naoUsa('Ainda não');

  const UsoWhatsApp(this.label);
  final String label;
}

enum TamanhoEquipe {
  ate3('1–3'),
  de4a10('4–10'),
  maisDe11('11+');

  const TamanhoEquipe(this.label);
  final String label;
}

/// Resultado final, só existe quando as três perguntas foram respondidas.
class QuestionarioRespostas {
  const QuestionarioRespostas({
    required this.papel,
    required this.whatsApp,
    required this.tamanhoEquipe,
  });

  final PapelAtendimento papel;
  final UsoWhatsApp whatsApp;
  final TamanhoEquipe tamanhoEquipe;

  Map<String, String> toJson() => {
        'papel': papel.name,
        'whatsApp': whatsApp.name,
        'tamanhoEquipe': tamanhoEquipe.name,
      };
}

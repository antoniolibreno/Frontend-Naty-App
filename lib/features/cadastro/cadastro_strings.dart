/// Textos da jornada de cadastro (evita strings soltas nos widgets).
abstract final class InicioStrings {
  static const titulo = 'Vamos implantar o seu atendimento.';
  static const subtitulo =
      'Assista, responda o quiz e configure.\nNo seu ritmo, sem reunião marcada.';
  static const chipTrilhas = '3 trilhas · 28 min';
  static const chipCertificado = 'Certificado no final';
  static const botaoComecar = 'Começar implantação';
  static const linkJaTenhoConta = 'Já tenho conta';
}

abstract final class QuestionarioStrings {
  static const passo = 'PASSO 0 DE 3';
  static const titulo = 'Antes de começar';
  static const subtitulo = 'Três respostas para montar a sua trilha.';
  static const perguntaPapel = 'Qual o seu papel no atendimento?';
  static const perguntaWhatsApp = 'A equipe já usa WhatsApp Business?';
  static const perguntaEquipe = 'Quantas pessoas vão atender?';
  static const botaoMontar = 'Montar minha trilha';
}

abstract final class QuizStrings {
  static const prefixoCategoria = 'Quiz';
  static const confirmar = 'Confirmar resposta';
  static const continuar = 'Continuar';
  static const finalizar = 'Finalizar quiz';
  static const feedbackCerto = 'Resposta correta!';
  static const feedbackErrado = 'Não foi dessa vez.';
  static const vazio = 'Nenhuma pergunta disponível para este quiz.';
  static const voltar = 'Voltar';
}

abstract final class ChecklistStrings {
  static const titulo = 'Checklist da trilha';
  static const subtitulo = 'Marque o que já está configurado no Naty App.';
  static const vazio = 'Esta trilha não tem itens para configurar.';

  static String trilhaDe(int n, int total) => 'Trilha $n de $total';
  static String contador(int marcados, int total) =>
      '$marcados/$total itens marcados';
  static String concluir(int n) => 'Concluir trilha $n';
}

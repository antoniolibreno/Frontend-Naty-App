/// Uma pergunta do quiz.
class QuizPergunta {
  const QuizPergunta({
    required this.categoria,
    required this.enunciado,
    required this.alternativas,
    required this.indiceCorreto,
  }) : assert(indiceCorreto >= 0);

  final String categoria;
  final String enunciado;
  final List<String> alternativas;
  final int indiceCorreto;

  factory QuizPergunta.fromJson(Map<String, dynamic> json) => QuizPergunta(
        categoria: json['categoria'] as String,
        enunciado: json['enunciado'] as String,
        alternativas: List<String>.from(json['alternativas'] as List),
        indiceCorreto: json['indiceCorreto'] as int,
      );
}

/// Resultado entregue ao final do quiz.
class QuizResultado {
  const QuizResultado({required this.acertos, required this.total});

  final int acertos;
  final int total;
}

/// Situação visual de cada alternativa.
enum AlternativaEstado { normal, selecionada, correta, incorreta, apagada }

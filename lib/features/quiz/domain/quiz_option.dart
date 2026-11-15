class QuizOption {
  const QuizOption({required this.id, required this.text});

  final String id;
  final String text;

  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
        id: json['id'] as String,
        text: (json['text'] ?? json['texto']) as String,
      );
}

enum AlternativaEstado { normal, selecionada, correta, incorreta, apagada }

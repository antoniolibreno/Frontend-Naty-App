import 'quiz_option.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.order,
    required this.statement,
    required this.options,
    this.explanation,
    this.correctOptionId,
  });

  final String id;
  final int order;
  final String statement;
  final List<QuizOption> options;
  final String? explanation;

  /// Present only in local/mock data. The API does not need to expose it.
  final String? correctOptionId;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] as String,
    order: (json['order'] ?? json['ordem']) as int,
    statement: (json['statement'] ?? json['enunciado']) as String,
    options: ((json['options'] ?? json['alternativas']) as List)
        .map(
          (option) => option is String
              ? QuizOption(id: option, text: option)
              : QuizOption.fromJson(option as Map<String, dynamic>),
        )
        .toList(),
    explanation: json['explanation'] as String?,
    correctOptionId: json['correctOptionId'] as String?,
  );
}

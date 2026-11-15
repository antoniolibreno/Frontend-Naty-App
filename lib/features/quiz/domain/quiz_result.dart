import 'quiz_answer.dart';

class QuizResult {
  const QuizResult({
    required this.answers,
    required this.score,
    required this.total,
    this.grade,
    this.approved,
    this.wrongQuestionIds = const {},
    this.nextActivityId,
  });

  final List<QuizAnswer> answers;
  final int score;
  final int total;
  final int? grade;
  final bool? approved;
  final Set<String> wrongQuestionIds;
  final String? nextActivityId;

  double get percentage => total == 0 ? 0 : score / total;
}

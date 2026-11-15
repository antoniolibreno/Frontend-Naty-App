import 'quiz_answer.dart';
import 'quiz_question.dart';
import 'quiz_result.dart';

class QuizContext {
  const QuizContext({
    required this.trilhaId,
    this.atividadeId,
    this.videoId,
    this.moduloId,
    this.quizId,
  });

  final String trilhaId;
  final String? atividadeId;
  final String? videoId;
  final String? moduloId;
  final String? quizId;
}

class Quiz {
  const Quiz({
    required this.id,
    required this.trilhaId,
    required this.atividadeId,
    required this.questions,
    this.videoId,
    this.moduloId,
  });

  final String id;
  final String trilhaId;
  final String atividadeId;
  final String? videoId;
  final String? moduloId;
  final List<QuizQuestion> questions;

  QuizResult evaluate(List<QuizAnswer> answers) {
    final byQuestion = {
      for (final answer in answers) answer.questionId: answer,
    };
    final score = questions.where((question) {
      return question.correctOptionId != null &&
          byQuestion[question.id]?.optionId == question.correctOptionId;
    }).length;
    return QuizResult(answers: answers, score: score, total: questions.length);
  }
}

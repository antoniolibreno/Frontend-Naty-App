import '../../quiz/domain/quiz_result.dart';

class NivelamentoResult {
  const NivelamentoResult({required this.quizResult, required this.level, required this.recommendedTrackId});
  final QuizResult quizResult;
  final String level;
  final String recommendedTrackId;
}

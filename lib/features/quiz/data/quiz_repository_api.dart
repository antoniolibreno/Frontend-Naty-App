import 'package:injectable/injectable.dart';
import 'package:natyapp/core/network/api_client.dart';

import '../domain/quiz.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_question.dart';
import '../domain/quiz_result.dart';

abstract class QuizRepository {
  Future<Quiz> fetchQuiz(QuizContext context);
  Future<QuizResult> submitAnswers(Quiz quiz, List<QuizAnswer> answers);
}

/// HTTP implementation seam. Wire this to GET /quizzes/{quizId} and
/// POST /quizzes/{quizId}/attempts when the backend contract is available.
@LazySingleton(as: QuizRepository)
class QuizRepositoryApi implements QuizRepository {
  QuizRepositoryApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Quiz> fetchQuiz(QuizContext context) async {
    final atividadeId = context.atividadeId;
    if (atividadeId == null) {
      throw ArgumentError('atividadeId é obrigatório para buscar o quiz.');
    }
    final json = await _apiClient.getJson(
      '/api/v1/atividades/$atividadeId/quiz',
    );
    return Quiz(
      id: json['id'] as String,
      trilhaId: context.trilhaId,
      atividadeId: atividadeId,
      videoId: context.videoId,
      moduloId: context.moduloId,
      questions: ((json['perguntas'] ?? const []) as List)
          .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<QuizResult> submitAnswers(Quiz quiz, List<QuizAnswer> answers) async {
    final atividadeId = quiz.atividadeId;
    final json = await _apiClient.postJson(
      '/api/v1/atividades/$atividadeId/quiz/tentativas',
      body: {
        'respostas': answers
            .map(
              (answer) => {
                'perguntaId': answer.questionId,
                'alternativaId': answer.optionId,
              },
            )
            .toList(),
      },
    );
    final nota = (json['nota'] as num).toInt();
    final perguntasErradas = ((json['perguntasErradas'] ?? const []) as List)
        .map((item) => (item as Map<String, dynamic>)['perguntaId'] as String)
        .toSet();
    return QuizResult(
      answers: answers,
      score: (nota * quiz.questions.length / 100).round(),
      total: quiz.questions.length,
      grade: nota,
      approved: json['aprovado'] as bool?,
      wrongQuestionIds: perguntasErradas,
      nextActivityId: json['proximaAtividadeId'] as String?,
    );
  }
}

import '../domain/quiz.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_option.dart';
import '../domain/quiz_question.dart';
import '../domain/quiz_result.dart';
import 'quiz_repository_api.dart';

class QuizRepositoryMock implements QuizRepository {
  @override
  Future<Quiz> fetchQuiz(QuizContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return Quiz(
      id: context.quizId ?? 'quiz-${context.trilhaId}',
      trilhaId: context.trilhaId,
      atividadeId: context.atividadeId ?? 'atividade-mock',
      videoId: context.videoId,
      moduloId: context.moduloId,
      questions: const [
        QuizQuestion(
          id: 'canais-01',
          order: 1,
          statement:
              'Ao conectar um novo canal, o que garante que a conversa chegue à fila correta?',
          options: [
            QuizOption(
              id: 'fila',
              text: 'Vincular o canal a uma fila de atendimento',
            ),
            QuizOption(
              id: 'nome',
              text: 'Renomear o canal com o nome da equipe',
            ),
            QuizOption(
              id: 'notificacao',
              text: 'Ativar as notificações no celular',
            ),
            QuizOption(
              id: 'etiqueta',
              text: 'Criar uma nova etiqueta de conversa',
            ),
          ],
          correctOptionId: 'fila',
          explanation:
              'A fila define para onde as novas conversas serão encaminhadas.',
        ),
        QuizQuestion(
          id: 'canais-02',
          order: 2,
          statement:
              'Qual canal permite automações e vários atendentes no mesmo número?',
          options: [
            QuizOption(id: 'app', text: 'WhatsApp app comum'),
            QuizOption(id: 'api', text: 'WhatsApp Business API oficial'),
            QuizOption(id: 'sms', text: 'SMS'),
            QuizOption(id: 'email', text: 'E-mail pessoal'),
          ],
          correctOptionId: 'api',
        ),
        QuizQuestion(
          id: 'canais-03',
          order: 3,
          statement: 'O que fazer antes de desconectar um canal em uso?',
          options: [
            QuizOption(id: 'nada', text: 'Nada, as conversas migram sozinhas'),
            QuizOption(id: 'filas', text: 'Apagar todas as filas'),
            QuizOption(
              id: 'transferir',
              text: 'Encerrar ou transferir as conversas abertas',
            ),
            QuizOption(id: 'senha', text: 'Trocar a senha da conta'),
          ],
          correctOptionId: 'transferir',
        ),
      ],
    );
  }

  @override
  Future<QuizResult> submitAnswers(Quiz quiz, List<QuizAnswer> answers) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return quiz.evaluate(answers);
  }
}

import '../../domain/quiz.dart';

sealed class QuizEvent { const QuizEvent(); }
final class QuizStarted extends QuizEvent { const QuizStarted(this.context); final QuizContext context; }
final class QuizAnswerSelected extends QuizEvent { const QuizAnswerSelected(this.questionId, this.optionId); final String questionId, optionId; }
final class QuizNextRequested extends QuizEvent { const QuizNextRequested(); }
final class QuizPreviousRequested extends QuizEvent { const QuizPreviousRequested(); }
final class QuizSubmitted extends QuizEvent { const QuizSubmitted(); }

import '../../domain/quiz.dart';
import '../../domain/quiz_result.dart';

sealed class QuizState { const QuizState(); }
final class QuizInitial extends QuizState { const QuizInitial(); }
final class QuizLoading extends QuizState { const QuizLoading(); }
final class QuizReady extends QuizState {
  const QuizReady(this.quiz, {this.currentIndex = 0, this.answers = const {}, this.confirmed = const {}});
  final Quiz quiz; final int currentIndex; final Map<String, String> answers; final Set<String> confirmed;
  QuizReady copyWith({int? currentIndex, Map<String, String>? answers, Set<String>? confirmed}) => QuizReady(quiz, currentIndex: currentIndex ?? this.currentIndex, answers: answers ?? this.answers, confirmed: confirmed ?? this.confirmed);
  bool get isAnswering => confirmed.contains(quiz.questions[currentIndex].id);
}
final class QuizAnswering extends QuizReady { const QuizAnswering(super.quiz, {super.currentIndex, super.answers, super.confirmed}); }
final class QuizSubmitting extends QuizReady { const QuizSubmitting(super.quiz, {super.currentIndex, super.answers, super.confirmed}); }
final class QuizCompleted extends QuizState { const QuizCompleted(this.result); final QuizResult result; }
final class QuizFailure extends QuizState { const QuizFailure(this.message); final String message; }

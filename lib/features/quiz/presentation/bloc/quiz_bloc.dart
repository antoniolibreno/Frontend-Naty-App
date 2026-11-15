import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/quiz_repository_api.dart';
import '../../domain/quiz_answer.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc(this._repository) : super(const QuizInitial()) {
    on<QuizStarted>(_started);
    on<QuizAnswerSelected>(_selected);
    on<QuizNextRequested>(_next);
    on<QuizPreviousRequested>(_previous);
    on<QuizSubmitted>(_submitted);
  }
  final QuizRepository _repository;

  Future<void> _started(QuizStarted event, Emitter<QuizState> emit) async {
    emit(const QuizLoading());
    try { emit(QuizReady(await _repository.fetchQuiz(event.context))); }
    catch (error) { emit(QuizFailure(error.toString())); }
  }
  void _selected(QuizAnswerSelected event, Emitter<QuizState> emit) {
    final current = state;
    if (current is! QuizReady || current.isAnswering) return;
    final answers = {...current.answers, event.questionId: event.optionId};
    emit(QuizAnswering(current.quiz, currentIndex: current.currentIndex, answers: answers, confirmed: current.confirmed));
  }
  void _next(QuizNextRequested event, Emitter<QuizState> emit) {
    final current = state;
    if (current is! QuizReady) return;
    final question = current.quiz.questions[current.currentIndex];
    if (!current.answers.containsKey(question.id)) return;
    if (!current.confirmed.contains(question.id)) {
      emit(QuizAnswering(current.quiz, currentIndex: current.currentIndex, answers: current.answers, confirmed: {...current.confirmed, question.id}));
      return;
    }
    final confirmed = {...current.confirmed, question.id};
    if (current.currentIndex == current.quiz.questions.length - 1) {
      add(const QuizSubmitted());
    } else {
      emit(QuizAnswering(current.quiz, currentIndex: current.currentIndex + 1, answers: current.answers, confirmed: confirmed));
    }
  }
  void _previous(QuizPreviousRequested event, Emitter<QuizState> emit) {
    final current = state;
    if (current is QuizReady && current.currentIndex > 0) emit(current.copyWith(currentIndex: current.currentIndex - 1));
  }
  Future<void> _submitted(QuizSubmitted event, Emitter<QuizState> emit) async {
    final current = state;
    if (current is! QuizReady) return;
    emit(QuizSubmitting(current.quiz, currentIndex: current.currentIndex, answers: current.answers, confirmed: current.confirmed));
    try {
      final answers = current.answers.entries.map((entry) => QuizAnswer(questionId: entry.key, optionId: entry.value)).toList();
      emit(QuizCompleted(await _repository.submitAnswers(current.quiz, answers)));
    } catch (error) { emit(QuizFailure(error.toString())); }
  }
}

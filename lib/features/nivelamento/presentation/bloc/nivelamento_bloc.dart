import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/nivelamento_repository_mock.dart';
import '../../domain/nivelamento_result.dart';
import '../../../quiz/domain/quiz_result.dart';

sealed class NivelamentoState { const NivelamentoState(); }
final class NivelamentoInitial extends NivelamentoState { const NivelamentoInitial(); }
final class NivelamentoCalculating extends NivelamentoState { const NivelamentoCalculating(); }
final class NivelamentoCompleted extends NivelamentoState { const NivelamentoCompleted(this.result); final NivelamentoResult result; }
final class NivelamentoFailure extends NivelamentoState { const NivelamentoFailure(this.message); final String message; }
final class NivelamentoResultRequested { const NivelamentoResultRequested(this.result); final QuizResult result; }

class NivelamentoBloc extends Bloc<NivelamentoResultRequested, NivelamentoState> {
  NivelamentoBloc(this._repository) : super(const NivelamentoInitial()) { on<NivelamentoResultRequested>(_calculate); }
  final NivelamentoRepository _repository;
  Future<void> _calculate(NivelamentoResultRequested event, Emitter<NivelamentoState> emit) async {
    emit(const NivelamentoCalculating());
    try { emit(NivelamentoCompleted(await _repository.calculate(event.result))); } catch (error) { emit(NivelamentoFailure(error.toString())); }
  }
}

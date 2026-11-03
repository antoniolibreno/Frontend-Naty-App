import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/progresso_repository.dart';
import '../mensagens_erro.dart';
import 'conclusao_event.dart';
import 'conclusao_state.dart';

@injectable
class ConclusaoBloc extends Bloc<ConclusaoEvent, ConclusaoState> {
  ConclusaoBloc(this._repository) : super(const ConclusaoInicial()) {
    on<ConclusaoSolicitada>(_onSolicitada);
  }

  final ProgressoRepository _repository;

  Future<void> _onSolicitada(
    ConclusaoSolicitada event,
    Emitter<ConclusaoState> emit,
  ) async {
    emit(const ConclusaoCarregando());
    try {
      emit(ConclusaoCarregada(await _repository.buscarConclusao()));
    } catch (erro, pilha) {
      addError(erro, pilha);
      emit(ConclusaoFalha(mensagemDeErro(erro, tela: TelaDoErro.conclusao)));
    }
  }
}

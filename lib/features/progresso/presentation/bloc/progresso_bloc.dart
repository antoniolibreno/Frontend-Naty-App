import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/progresso_repository.dart';
import '../mensagens_erro.dart';
import 'progresso_event.dart';
import 'progresso_state.dart';

@injectable
class ProgressoBloc extends Bloc<ProgressoEvent, ProgressoState> {
  ProgressoBloc(this._repository) : super(const ProgressoInicial()) {
    on<ProgressoSolicitado>(_onSolicitado);
    on<ProgressoAtualizacaoSolicitada>(_onAtualizacaoSolicitada);
  }

  final ProgressoRepository _repository;

  Future<void> _onSolicitado(
    ProgressoSolicitado event,
    Emitter<ProgressoState> emit,
  ) async {
    emit(const ProgressoCarregando());
    try {
      emit(ProgressoCarregado(await _repository.buscarResumo()));
    } catch (erro, pilha) {
      addError(erro, pilha);
      emit(ProgressoFalha(mensagemDeErro(erro, tela: TelaDoErro.progresso)));
    }
  }

  Future<void> _onAtualizacaoSolicitada(
    ProgressoAtualizacaoSolicitada event,
    Emitter<ProgressoState> emit,
  ) async {
    final atual = state;
    if (atual is! ProgressoCarregado) {
      return _onSolicitado(const ProgressoSolicitado(), emit);
    }
    try {
      emit(ProgressoCarregado(await _repository.buscarResumo()));
    } catch (erro, pilha) {
      addError(erro, pilha);
      emit(
        ProgressoCarregado(
          atual.resumo,
          falhaAtualizacao: mensagemDeErro(erro, tela: TelaDoErro.progresso),
        ),
      );
    }
  }
}

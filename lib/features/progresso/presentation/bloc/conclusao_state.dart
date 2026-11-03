import '../../domain/resumo_conclusao.dart';

sealed class ConclusaoState {
  const ConclusaoState();
}

final class ConclusaoInicial extends ConclusaoState {
  const ConclusaoInicial();
}

final class ConclusaoCarregando extends ConclusaoState {
  const ConclusaoCarregando();
}

final class ConclusaoCarregada extends ConclusaoState {
  const ConclusaoCarregada(this.resumo);

  final ResumoConclusao resumo;
}

final class ConclusaoFalha extends ConclusaoState {
  const ConclusaoFalha(this.message);

  final String message;
}

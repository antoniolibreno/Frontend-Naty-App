import '../../domain/resumo_progresso.dart';

sealed class ProgressoState {
  const ProgressoState();
}

final class ProgressoInicial extends ProgressoState {
  const ProgressoInicial();
}

final class ProgressoCarregando extends ProgressoState {
  const ProgressoCarregando();
}

final class ProgressoCarregado extends ProgressoState {
  const ProgressoCarregado(this.resumo, {this.falhaAtualizacao});

  final ResumoProgresso resumo;

  /// Mensagem de uma atualização que falhou. Os dados em [resumo] continuam
  /// sendo os últimos carregados com sucesso.
  final String? falhaAtualizacao;
}

final class ProgressoFalha extends ProgressoState {
  const ProgressoFalha(this.message);

  final String message;
}

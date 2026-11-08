/// Erro de domínio que pode ser apresentado ou tratado pela aplicação.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Ocorreu um erro inesperado.']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Não foi possível conectar ao servidor.',
  ]);
}

/// Resposta de erro da API, no formato `ErroResposta` do back: [status] HTTP,
/// [codigo] de negócio (quando houver) e a `mensagem` do back em [message].
final class ApiFailure extends Failure {
  const ApiFailure({
    required this.status,
    this.codigo,
    String message = 'O servidor recusou a requisição.',
  }) : super(message);

  final int status;
  final String? codigo;
}


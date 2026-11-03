import 'package:natyapp/core/error/failure.dart';

/// Tela em que o erro aconteceu, para a mensagem falar do que o integrante
/// estava tentando ver.
enum TelaDoErro { progresso, conclusao }

/// Código de erro que o back devolve quando o selo ainda não foi emitido
/// (ver `docs/contrato-progresso.md`).
const codigoConclusaoNaoEmitida = 'CONCLUSAO_NAO_EMITIDA';

/// Traduz qualquer erro vindo do repositório numa frase que o integrante
/// entende e que diz o que fazer em seguida. Detalhes técnicos ficam no log
/// (o bloc registra o erro original com `addError`).
String mensagemDeErro(Object erro, {required TelaDoErro tela}) {
  final oQue = switch (tela) {
    TelaDoErro.progresso => 'seu progresso',
    TelaDoErro.conclusao => 'seu selo de conclusão',
  };

  return switch (erro) {
    NetworkFailure() =>
      'Sem conexão com o servidor. Verifique sua internet e tente de novo.',
    ApiFailure(codigo: codigoConclusaoNaoEmitida) => _conclusaoNaoEmitida,
    ApiFailure(status: 404) when tela == TelaDoErro.conclusao =>
      _conclusaoNaoEmitida,
    ApiFailure(status: 401) =>
      'Sua sessão expirou. Saia e entre de novo no app.',
    ApiFailure(status: 403) =>
      'Sua conta não tem acesso a $oQue. '
          'Fale com o administrador da sua empresa.',
    ApiFailure(:final status) when status >= 500 =>
      'O servidor está instável no momento. '
          'Tente de novo em alguns minutos.',
    FormatException() =>
      'Recebemos dados inesperados do servidor. '
          'Tente de novo mais tarde.',
    _ => 'Não foi possível carregar $oQue. Tente de novo.',
  };
}

const _conclusaoNaoEmitida =
    'Você ainda não concluiu a implantação. '
    'Termine as trilhas e o checklist para receber o selo.';

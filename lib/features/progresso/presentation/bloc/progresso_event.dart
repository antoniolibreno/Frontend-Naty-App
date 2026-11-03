sealed class ProgressoEvent {
  const ProgressoEvent();
}

/// Carrega (ou recarrega, após uma falha) o resumo de progresso, mostrando o
/// indicador de carregamento no lugar do conteúdo.
final class ProgressoSolicitado extends ProgressoEvent {
  const ProgressoSolicitado();
}

/// Atualiza o resumo já exibido (puxar para atualizar). O conteúdo continua
/// na tela durante a busca, e uma falha não apaga os dados anteriores.
final class ProgressoAtualizacaoSolicitada extends ProgressoEvent {
  const ProgressoAtualizacaoSolicitada();
}

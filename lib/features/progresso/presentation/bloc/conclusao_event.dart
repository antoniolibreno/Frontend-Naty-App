sealed class ConclusaoEvent {
  const ConclusaoEvent();
}

/// Carrega (ou recarrega, após uma falha) os dados do selo de conclusão.
final class ConclusaoSolicitada extends ConclusaoEvent {
  const ConclusaoSolicitada();
}

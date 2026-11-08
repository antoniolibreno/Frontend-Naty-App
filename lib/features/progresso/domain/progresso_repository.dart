import 'resumo_conclusao.dart';
import 'resumo_progresso.dart';

/// Fonte dos dados de progresso e de conclusão do integrante.
///
/// A API ainda não expõe XP somado, nível, sequência de dias, conquistas nem
/// selo de conclusão, então a implementação registrada é
/// `ProgressoRepositoryMock`. A implementação real já existe em
/// `ProgressoRepositoryApi`, com o passo a passo para ligá-la. O contrato
/// esperado do back está em `docs/contrato-progresso.md`.
abstract interface class ProgressoRepository {
  Future<ResumoProgresso> buscarResumo();

  Future<ResumoConclusao> buscarConclusao();
}

import 'package:injectable/injectable.dart';

import '../domain/progresso_repository.dart';
import '../domain/resumo_conclusao.dart';
import '../domain/resumo_progresso.dart';

/// Dados fixos, iguais aos do protótipo no Figma, enquanto a API não fornece
/// essas informações.
@LazySingleton(as: ProgressoRepository)
class ProgressoRepositoryMock implements ProgressoRepository {
  static const _latenciaSimulada = Duration(milliseconds: 300);

  @override
  Future<ResumoProgresso> buscarResumo() async {
    await Future<void>.delayed(_latenciaSimulada);
    return const ResumoProgresso(
      xpTotal: 240,
      nivel: 2,
      nomeNivel: 'Operador',
      xpInicioNivel: 200,
      xpProximoNivel: 400,
      diasSeguidos: 4,
      percentualAcertoQuiz: 92,
      trilhasConcluidas: 1,
      totalTrilhas: 3,
      conquistas: [
        Conquista(
          tipo: TipoConquista.primeiroCanal,
          titulo: 'Primeiro canal',
          conquistada: true,
        ),
        Conquista(
          tipo: TipoConquista.quizSemErro,
          titulo: 'Quiz sem erro',
          conquistada: true,
        ),
        Conquista(
          tipo: TipoConquista.sequenciaDias,
          titulo: 'Sequência de 4 dias',
          conquistada: true,
        ),
        Conquista(
          tipo: TipoConquista.implantacaoCompleta,
          titulo: 'Implantação completa',
          conquistada: false,
          pendencia: 'Faltam 2 trilhas',
        ),
      ],
    );
  }

  @override
  Future<ResumoConclusao> buscarConclusao() async {
    await Future<void>.delayed(_latenciaSimulada);
    return ResumoConclusao(
      nomeIntegrante: 'Marina Rocha',
      numeroSelo: 412,
      trilhasConcluidas: 3,
      totalTrilhas: 3,
      quizzesRealizados: 9,
      percentualAcertoQuiz: 92,
      itensConfiguracao: 14,
      emitidoEm: DateTime(2026, 8, 14),
    );
  }
}

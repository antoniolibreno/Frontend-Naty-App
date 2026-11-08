import 'package:natyapp/features/progresso/domain/progresso_repository.dart';
import 'package:natyapp/features/progresso/domain/resumo_conclusao.dart';
import 'package:natyapp/features/progresso/domain/resumo_progresso.dart';

/// Mesmos valores do protótipo no Figma.
const resumoDeTeste = ResumoProgresso(
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

final conclusaoDeTeste = ResumoConclusao(
  nomeIntegrante: 'Marina Rocha',
  numeroSelo: 412,
  trilhasConcluidas: 3,
  totalTrilhas: 3,
  quizzesRealizados: 9,
  percentualAcertoQuiz: 92,
  itensConfiguracao: 14,
  emitidoEm: DateTime(2026, 8, 14),
);

/// Repositório controlável pelos testes: responde na hora, conta as chamadas
/// e lança [erro] enquanto ele estiver definido.
class RepositorioFake implements ProgressoRepository {
  RepositorioFake({this.erro});

  Object? erro;
  int chamadasResumo = 0;
  int chamadasConclusao = 0;

  @override
  Future<ResumoProgresso> buscarResumo() async {
    chamadasResumo++;
    final falha = erro;
    if (falha != null) throw falha;
    return resumoDeTeste;
  }

  @override
  Future<ResumoConclusao> buscarConclusao() async {
    chamadasConclusao++;
    final falha = erro;
    if (falha != null) throw falha;
    return conclusaoDeTeste;
  }
}

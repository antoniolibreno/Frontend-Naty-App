import 'package:natyapp/features/gamification/data/gamification_repository.dart';
import 'package:natyapp/features/gamification/domain/gamification.dart';

Map<String, dynamic> summaryJson({
  int xp = 120,
  int streak = 0,
  bool empty = false,
}) => {
  'integranteId': 'member-1',
  'xpTotal': empty ? 0 : xp,
  'nivel': empty ? 1 : 2,
  'xpNoNivel': empty ? 0 : 20,
  'xpParaProximoNivel': empty ? 100 : 300,
  'percentualNivel': empty ? 0 : 6,
  'sequenciaAtual': streak,
  'maiorSequencia': streak + 2,
  'ultimoDiaAtivo': empty ? null : '2026-11-15',
  'quizzes': {
    'tentativas': empty ? 0 : 3,
    'aprovados': empty ? 0 : 2,
    'melhorNota': empty ? null : 100,
    'mediaNotas': empty ? 0 : 86.7,
    'percentualAcerto': empty ? 0 : 90.5,
  },
  'conquistas': empty
      ? []
      : [
          {
            'id': 'achievement-1',
            'codigo': 'PRIMEIRA_ATIVIDADE',
            'titulo': 'Primeiro passo',
            'descricao': 'Conclua sua primeira atividade.',
            'concedidaEm': '2026-11-15T12:00:00Z',
          },
          {
            'id': 'achievement-2',
            'codigo': 'QUIZ_PERFEITO',
            'titulo': 'Acerto perfeito',
            'descricao': 'Acerte 100% de um quiz.',
            'concedidaEm': '2026-11-15T13:00:00Z',
          },
        ],
};

RankingPage rankingPage(int page) => RankingPage(
  items: [
    RankingEntry(
      memberId: page == 0 ? 'member-1' : 'member-2',
      name: page == 0 ? 'Marina Rocha' : 'Rafael Silva',
      position: page + 1,
      totalXp: page == 0 ? 120 : 100,
      level: 2,
      currentStreak: 3,
    ),
  ],
  page: page,
  size: 20,
  totalItems: 2,
  totalPages: 2,
);

class FakeGamificationRepository implements GamificationRepository {
  Gamification summary = Gamification.fromJson(summaryJson());
  bool failSummary = false;
  bool failRanking = false;
  final summaryIds = <String>[];
  final pages = <int>[];
  @override
  Future<Gamification> fetchSummary(String memberId) async {
    summaryIds.add(memberId);
    if (failSummary) throw Exception('Falha simulada');
    return summary;
  }

  @override
  Future<RankingPage> fetchRanking({int page = 0, int size = 20}) async {
    pages.add(page);
    if (failRanking) throw Exception('Falha simulada');
    return rankingPage(page);
  }
}

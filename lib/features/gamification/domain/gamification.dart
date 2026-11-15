import '../../progresso/domain/leitura_json.dart';

class QuizStatistics {
  const QuizStatistics({
    required this.attempts,
    required this.approved,
    required this.bestScore,
    required this.average,
    required this.accuracy,
  });
  factory QuizStatistics.fromJson(Map<String, dynamic> json) => QuizStatistics(
    attempts: lerInteiro(json, 'tentativas'),
    approved: lerInteiro(json, 'aprovados'),
    bestScore: json['melhorNota'] == null
        ? null
        : lerInteiro(json, 'melhorNota'),
    average: (json['mediaNotas'] as num).toDouble(),
    accuracy: (json['percentualAcerto'] as num).toDouble(),
  );
  final int attempts, approved;
  final int? bestScore;
  final double average, accuracy;
}

class Achievement {
  const Achievement({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.grantedAt,
  });
  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: lerTexto(json, 'id'),
    code: lerTexto(json, 'codigo'),
    title: lerTexto(json, 'titulo'),
    description: lerTexto(json, 'descricao'),
    grantedAt: lerData(json, 'concedidaEm'),
  );
  final String id, code, title, description;
  final DateTime grantedAt;
}

class Gamification {
  const Gamification({
    required this.memberId,
    required this.totalXp,
    required this.level,
    required this.xpInLevel,
    required this.xpRequiredInLevel,
    required this.levelPercent,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
    required this.quizzes,
    required this.achievements,
  });
  factory Gamification.fromJson(Map<String, dynamic> json) => Gamification(
    memberId: lerTexto(json, 'integranteId'),
    totalXp: lerInteiro(json, 'xpTotal'),
    level: lerInteiro(json, 'nivel'),
    xpInLevel: lerInteiro(json, 'xpNoNivel'),
    xpRequiredInLevel: lerInteiro(json, 'xpParaProximoNivel'),
    levelPercent: lerInteiro(json, 'percentualNivel'),
    currentStreak: lerInteiro(json, 'sequenciaAtual'),
    longestStreak: lerInteiro(json, 'maiorSequencia'),
    lastActiveDate: json['ultimoDiaAtivo'] == null
        ? null
        : DateTime.parse(lerTexto(json, 'ultimoDiaAtivo')),
    quizzes: QuizStatistics.fromJson(json['quizzes'] as Map<String, dynamic>),
    achievements: lerLista(json, 'conquistas', Achievement.fromJson),
  );
  final String memberId;
  final int totalXp,
      level,
      xpInLevel,
      xpRequiredInLevel,
      levelPercent,
      currentStreak,
      longestStreak;
  final DateTime? lastActiveDate;
  final QuizStatistics quizzes;
  final List<Achievement> achievements;
  // O backend chama a faixa inteira do nível de xpParaProximoNivel.
  int get xpRemaining =>
      (xpRequiredInLevel - xpInLevel).clamp(0, xpRequiredInLevel);
}

class RankingEntry {
  const RankingEntry({
    required this.memberId,
    required this.name,
    required this.position,
    required this.totalXp,
    required this.level,
    required this.currentStreak,
  });
  factory RankingEntry.fromJson(Map<String, dynamic> json) => RankingEntry(
    memberId: lerTexto(json, 'integranteId'),
    name: lerTexto(json, 'nome'),
    position: lerInteiro(json, 'posicao'),
    totalXp: lerInteiro(json, 'xpTotal'),
    level: lerInteiro(json, 'nivel'),
    currentStreak: lerInteiro(json, 'sequenciaAtual'),
  );
  final String memberId, name;
  final int position, totalXp, level, currentStreak;
}

class RankingPage {
  const RankingPage({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
  });
  factory RankingPage.fromJson(Map<String, dynamic> json) => RankingPage(
    items: lerLista(json, 'itens', RankingEntry.fromJson),
    page: lerInteiro(json, 'pagina'),
    size: lerInteiro(json, 'tamanho'),
    totalItems: lerInteiro(json, 'totalItens'),
    totalPages: lerInteiro(json, 'totalPaginas'),
  );
  final List<RankingEntry> items;
  final int page, size, totalItems, totalPages;
  bool get hasMore => page + 1 < totalPages;
}

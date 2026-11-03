import 'leitura_json.dart';

/// Tipos de conquista conhecidos pelo app. A tela usa o tipo para escolher o
/// ícone, então o domínio não depende de nada do Flutter.
///
/// [outra] cobre conquistas que o back criar depois sem o app ser atualizado:
/// elas aparecem com um ícone genérico em vez de quebrar a tela.
enum TipoConquista {
  primeiroCanal('PRIMEIRO_CANAL'),
  quizSemErro('QUIZ_SEM_ERRO'),
  sequenciaDias('SEQUENCIA_DIAS'),
  implantacaoCompleta('IMPLANTACAO_COMPLETA'),
  outra('');

  const TipoConquista(this.codigo);

  /// Código usado pela API (campo `codigo` da conquista).
  final String codigo;

  static TipoConquista doCodigo(String codigo) => values.firstWhere(
    (tipo) => tipo != outra && tipo.codigo == codigo,
    orElse: () => outra,
  );
}

final class Conquista {
  const Conquista({
    required this.tipo,
    required this.titulo,
    required this.conquistada,
    this.pendencia,
  });

  /// Lê uma conquista no formato descrito em `docs/contrato-progresso.md`.
  factory Conquista.fromJson(Map<String, dynamic> json) => Conquista(
    tipo: TipoConquista.doCodigo(lerTexto(json, 'codigo')),
    titulo: lerTexto(json, 'titulo'),
    conquistada: lerBool(json, 'conquistada'),
    pendencia: lerTextoOpcional(json, 'pendencia'),
  );

  final TipoConquista tipo;
  final String titulo;
  final bool conquistada;

  /// O que falta para obter a conquista, exibido quando ela ainda está
  /// bloqueada (ex.: "Faltam 2 trilhas").
  final String? pendencia;
}

/// Resumo da evolução do integrante, exibido na tela "Seu progresso".
final class ResumoProgresso {
  const ResumoProgresso({
    required this.xpTotal,
    required this.nivel,
    required this.nomeNivel,
    required this.xpInicioNivel,
    required this.xpProximoNivel,
    required this.diasSeguidos,
    required this.percentualAcertoQuiz,
    required this.trilhasConcluidas,
    required this.totalTrilhas,
    required this.conquistas,
  });

  /// Lê o resumo no formato descrito em `docs/contrato-progresso.md`.
  factory ResumoProgresso.fromJson(Map<String, dynamic> json) =>
      ResumoProgresso(
        xpTotal: lerInteiro(json, 'xpTotal'),
        nivel: lerInteiro(json, 'nivel'),
        nomeNivel: lerTexto(json, 'nomeNivel'),
        xpInicioNivel: lerInteiro(json, 'xpInicioNivel'),
        xpProximoNivel: lerInteiro(json, 'xpProximoNivel'),
        diasSeguidos: lerInteiro(json, 'diasSeguidos'),
        percentualAcertoQuiz: lerInteiro(json, 'percentualAcertoQuiz'),
        trilhasConcluidas: lerInteiro(json, 'trilhasConcluidas'),
        totalTrilhas: lerInteiro(json, 'totalTrilhas'),
        conquistas: lerLista(json, 'conquistas', Conquista.fromJson),
      );

  final int xpTotal;
  final int nivel;
  final String nomeNivel;

  /// XP em que o nível atual começa.
  final int xpInicioNivel;

  /// XP em que o próximo nível começa.
  final int xpProximoNivel;

  final int diasSeguidos;
  final int percentualAcertoQuiz;
  final int trilhasConcluidas;
  final int totalTrilhas;
  final List<Conquista> conquistas;

  int get xpParaProximoNivel =>
      xpProximoNivel > xpTotal ? xpProximoNivel - xpTotal : 0;

  /// Fração de 0 a 1 do caminho percorrido dentro do nível atual.
  double get progressoNoNivel {
    final faixa = xpProximoNivel - xpInicioNivel;
    if (faixa <= 0) return 1;
    return ((xpTotal - xpInicioNivel) / faixa).clamp(0.0, 1.0);
  }
}

import 'leitura_json.dart';

/// Dados do selo emitido quando o integrante conclui a implantação.
final class ResumoConclusao {
  const ResumoConclusao({
    required this.nomeIntegrante,
    required this.numeroSelo,
    required this.trilhasConcluidas,
    required this.totalTrilhas,
    required this.quizzesRealizados,
    required this.percentualAcertoQuiz,
    required this.itensConfiguracao,
    required this.emitidoEm,
  });

  /// Lê o selo no formato descrito em `docs/contrato-progresso.md`.
  factory ResumoConclusao.fromJson(Map<String, dynamic> json) =>
      ResumoConclusao(
        nomeIntegrante: lerTexto(json, 'nomeIntegrante'),
        numeroSelo: lerInteiro(json, 'numeroSelo'),
        trilhasConcluidas: lerInteiro(json, 'trilhasConcluidas'),
        totalTrilhas: lerInteiro(json, 'totalTrilhas'),
        quizzesRealizados: lerInteiro(json, 'quizzesRealizados'),
        percentualAcertoQuiz: lerInteiro(json, 'percentualAcertoQuiz'),
        itensConfiguracao: lerInteiro(json, 'itensConfiguracao'),
        emitidoEm: lerData(json, 'emitidoEm'),
      );

  final String nomeIntegrante;
  final int numeroSelo;
  final int trilhasConcluidas;
  final int totalTrilhas;
  final int quizzesRealizados;
  final int percentualAcertoQuiz;
  final int itensConfiguracao;
  final DateTime emitidoEm;

  String get primeiroNome {
    final partes = _partesDoNome;
    return partes.isEmpty ? '' : partes.first;
  }

  /// Iniciais do primeiro e do último nome, ou as duas primeiras letras quando
  /// só existe um nome.
  String get iniciais {
    final partes = _partesDoNome;
    if (partes.isEmpty) return '';
    if (partes.length == 1) {
      final nome = partes.first;
      return nome.substring(0, nome.length < 2 ? nome.length : 2).toUpperCase();
    }
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  List<String> get _partesDoNome => nomeIntegrante
      .trim()
      .split(RegExp(r'\s+'))
      .where((parte) => parte.isNotEmpty)
      .toList();
}

import 'package:flutter/foundation.dart';

import 'quiz_models.dart';

/// Estado do quiz: pergunta atual, alternativa escolhida e acertos.
///
/// Fluxo de cada pergunta:
///   escolher alternativa → "Confirmar resposta" → feedback (certa/errada)
///   → "Continuar" → próxima pergunta (ou fim).
class QuizController extends ChangeNotifier {
  QuizController(this.perguntas);

  final List<QuizPergunta> perguntas;

  int _indice = 0;
  int? _selecionada;
  bool _confirmada = false;
  int _acertos = 0;

  int get indice => _indice;
  int? get selecionada => _selecionada;
  bool get confirmada => _confirmada;
  int get acertos => _acertos;

  bool get vazio => perguntas.isEmpty;
  int get total => perguntas.length;
  QuizPergunta get atual => perguntas[_indice];
  bool get ultima => _indice == total - 1;
  bool get acertou => _confirmada && _selecionada == atual.indiceCorreto;

  void selecionar(int i) {
    if (_confirmada) return; // depois de confirmar, a escolha fica travada
    _selecionada = i;
    notifyListeners();
  }

  void confirmar() {
    if (_selecionada == null || _confirmada) return;
    _confirmada = true;
    if (_selecionada == atual.indiceCorreto) _acertos++;
    notifyListeners();
  }

  /// Avança para a próxima pergunta. Retorna o resultado se o quiz acabou.
  QuizResultado? avancar() {
    if (!_confirmada) return null;
    if (ultima) return QuizResultado(acertos: _acertos, total: total);

    _indice++;
    _selecionada = null;
    _confirmada = false;
    notifyListeners();
    return null;
  }

  AlternativaEstado estadoDe(int i) {
    if (!_confirmada) {
      return i == _selecionada
          ? AlternativaEstado.selecionada
          : AlternativaEstado.normal;
    }
    if (i == atual.indiceCorreto) return AlternativaEstado.correta;
    if (i == _selecionada) return AlternativaEstado.incorreta;
    return AlternativaEstado.apagada;
  }
}

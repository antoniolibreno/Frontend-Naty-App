import 'package:flutter/foundation.dart';

import 'checklist_models.dart';

/// Salva os ids marcados (API/Firebase/local). Injetado de fora.
typedef SalvarChecklist = Future<void> Function(Set<String> idsMarcados);

/// Estado do checklist: itens marcados, envio e erro.
class ChecklistController extends ChangeNotifier {
  ChecklistController({
    required this.trilha,
    required SalvarChecklist salvar,
    Set<String> marcadosIniciais = const {},
  })  : _salvar = salvar,
        _marcados = {...marcadosIniciais};

  final TrilhaChecklist trilha;
  final SalvarChecklist _salvar;
  final Set<String> _marcados;

  bool _salvando = false;
  String? _erro;

  bool get salvando => _salvando;
  String? get erro => _erro;
  int get totalMarcados => _marcados.length;
  int get totalItens => trilha.itens.length;
  bool get vazio => trilha.itens.isEmpty;

  bool marcado(String id) => _marcados.contains(id);

  void alternar(String id) {
    if (_salvando) return;
    _marcados.contains(id) ? _marcados.remove(id) : _marcados.add(id);
    _erro = null;
    notifyListeners();
  }

  /// Retorna true se salvou com sucesso.
  Future<bool> concluir() async {
    if (_salvando) return false;
    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      await _salvar(Set.unmodifiable(_marcados));
      return true;
    } catch (_) {
      _erro = 'Não foi possível concluir a trilha. Tente novamente.';
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }
}

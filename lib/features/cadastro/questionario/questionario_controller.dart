import 'package:flutter/foundation.dart';

import 'questionario_models.dart';

/// Função que envia as respostas (API, Firebase, local...). Injetada de fora
/// para o controller não depender do backend que o grupo escolher.
typedef EnviarRespostas = Future<void> Function(QuestionarioRespostas respostas);

/// Estado da tela do questionário.
///
/// Usa só `ChangeNotifier` (nativo do Flutter), então funciona sem pacote
/// extra e é fácil de migrar para Provider/Riverpod/Bloc depois.
class QuestionarioController extends ChangeNotifier {
  QuestionarioController({required EnviarRespostas enviar}) : _enviar = enviar;

  final EnviarRespostas _enviar;

  PapelAtendimento? _papel;
  UsoWhatsApp? _whatsApp;
  TamanhoEquipe? _tamanhoEquipe;
  bool _enviando = false;
  String? _erro;

  PapelAtendimento? get papel => _papel;
  UsoWhatsApp? get whatsApp => _whatsApp;
  TamanhoEquipe? get tamanhoEquipe => _tamanhoEquipe;
  bool get enviando => _enviando;
  String? get erro => _erro;

  bool get completo =>
      _papel != null && _whatsApp != null && _tamanhoEquipe != null;

  void selecionarPapel(PapelAtendimento v) => _set(() => _papel = v);
  void selecionarWhatsApp(UsoWhatsApp v) => _set(() => _whatsApp = v);
  void selecionarTamanho(TamanhoEquipe v) => _set(() => _tamanhoEquipe = v);

  void _set(VoidCallback change) {
    if (_enviando) return; // trava as opções durante o envio
    change();
    _erro = null;
    notifyListeners();
  }

  /// Retorna as respostas em caso de sucesso, ou null se falhar/incompleto.
  Future<QuestionarioRespostas?> enviar() async {
    if (!completo || _enviando) return null;

    final respostas = QuestionarioRespostas(
      papel: _papel!,
      whatsApp: _whatsApp!,
      tamanhoEquipe: _tamanhoEquipe!,
    );

    _enviando = true;
    _erro = null;
    notifyListeners();

    try {
      await _enviar(respostas);
      return respostas;
    } catch (_) {
      _erro = 'Não foi possível montar sua trilha. Tente novamente.';
      return null;
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }
}

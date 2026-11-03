/// Leitura tipada de campos de JSON. Campo ausente ou com tipo errado lança
/// [FormatException] com o nome do campo, o que deixa claro qual parte do
/// contrato com o back foi quebrada.
library;

int lerInteiro(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is num) return valor.toInt();
  throw FormatException('Campo "$campo" deveria ser número, veio: $valor');
}

String lerTexto(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is String) return valor;
  throw FormatException('Campo "$campo" deveria ser texto, veio: $valor');
}

String? lerTextoOpcional(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor == null || valor is String) return valor as String?;
  throw FormatException('Campo "$campo" deveria ser texto, veio: $valor');
}

bool lerBool(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is bool) return valor;
  throw FormatException('Campo "$campo" deveria ser true/false, veio: $valor');
}

/// Lê uma data em ISO 8601 (ex.: "2026-08-14T15:30:00Z") no fuso do aparelho.
DateTime lerData(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  final data = valor is String ? DateTime.tryParse(valor) : null;
  if (data != null) return data.toLocal();
  throw FormatException(
    'Campo "$campo" deveria ser data ISO 8601, veio: $valor',
  );
}

List<T> lerLista<T>(
  Map<String, dynamic> json,
  String campo,
  T Function(Map<String, dynamic>) converter,
) {
  final valor = json[campo];
  if (valor is List) {
    return [
      for (final item in valor)
        if (item is Map<String, dynamic>)
          converter(item)
        else
          throw FormatException('Item de "$campo" deveria ser objeto: $item'),
    ];
  }
  throw FormatException('Campo "$campo" deveria ser lista, veio: $valor');
}

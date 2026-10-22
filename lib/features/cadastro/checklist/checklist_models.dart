/// Item do checklist da trilha.
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.titulo,
    required this.caminho,
  });

  /// Identificador estável, usado para salvar o que foi marcado.
  final String id;
  final String titulo;

  /// Caminho no Naty App onde a configuração é feita,
  /// ex.: ['Canais', 'Conexões', 'Ler QR Code'].
  final List<String> caminho;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        caminho: List<String>.from(json['caminho'] as List),
      );
}

/// Dados de uma trilha exibidos no checklist.
class TrilhaChecklist {
  const TrilhaChecklist({
    required this.numero,
    required this.totalTrilhas,
    required this.itens,
  });

  final int numero;
  final int totalTrilhas;
  final List<ChecklistItem> itens;
}

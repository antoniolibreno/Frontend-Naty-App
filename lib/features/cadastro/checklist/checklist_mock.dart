import 'checklist_models.dart';

/// Itens da trilha 1, conforme o Figma. Substituir pelos dados do backend.
const trilha1ChecklistMock = TrilhaChecklist(
  numero: 1,
  totalTrilhas: 3,
  itens: [
    ChecklistItem(
      id: 'numero_conectado',
      titulo: 'Número conectado e validado',
      caminho: ['Canais', 'Conexões', 'Ler QR Code'],
    ),
    ChecklistItem(
      id: 'canal_fila',
      titulo: 'Canal vinculado a uma fila',
      caminho: ['Canais', 'Editar', 'Fila padrão'],
    ),
    ChecklistItem(
      id: 'horario_atendimento',
      titulo: 'Horário de atendimento definido',
      caminho: ['Empresa', 'Horários'],
    ),
    ChecklistItem(
      id: 'mensagem_ausencia',
      titulo: 'Mensagem de ausência ativa',
      caminho: ['Conversas', 'Automações'],
    ),
  ],
);

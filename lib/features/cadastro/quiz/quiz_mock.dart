import 'quiz_models.dart';

/// Perguntas de exemplo enquanto o conteúdo real não vem do backend.
/// A primeira é a do Figma; as outras duas são PROVISÓRIAS, só para testar
/// o fluxo de 3 perguntas. Substituir pelo conteúdo definido pelo grupo.
const quizCanaisMock = <QuizPergunta>[
  QuizPergunta(
    categoria: 'Canais e conexões',
    enunciado:
        'Ao conectar um novo canal, o que garante que a conversa chegue à fila correta?',
    alternativas: [
      'Vincular o canal a uma fila de atendimento',
      'Renomear o canal com o nome da equipe',
      'Ativar as notificações no celular',
      'Criar uma nova etiqueta de conversa',
    ],
    indiceCorreto: 0,
  ),
  QuizPergunta(
    categoria: 'Canais e conexões',
    enunciado: 'Qual canal permite automações e vários atendentes no mesmo número?',
    alternativas: [
      'WhatsApp app comum',
      'WhatsApp Business API oficial',
      'SMS',
      'E-mail pessoal',
    ],
    indiceCorreto: 1,
  ),
  QuizPergunta(
    categoria: 'Canais e conexões',
    enunciado: 'O que fazer antes de desconectar um canal em uso?',
    alternativas: [
      'Nada, as conversas migram sozinhas',
      'Apagar todas as filas',
      'Encerrar ou transferir as conversas abertas',
      'Trocar a senha da conta',
    ],
    indiceCorreto: 2,
  ),
];

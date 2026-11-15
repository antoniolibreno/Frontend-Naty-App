import '../../quiz/domain/quiz_question.dart';
import '../../quiz/domain/quiz_option.dart';

/// Conteúdo próprio do diagnóstico, pronto para ser preenchido pela API.
const nivelamentoInicialMock = <QuizQuestion>[
  QuizQuestion(
    id: 'nivelamento-01', order: 1,
    statement: 'Ao conectar um novo canal, o que garante que a conversa chegue à fila correta?',
    options: [
      QuizOption(id: 'fila', text: 'Vincular o canal a uma fila de atendimento'),
      QuizOption(id: 'nome', text: 'Renomear o canal com o nome da equipe'),
      QuizOption(id: 'notificacao', text: 'Ativar as notificações no celular'),
    ],
    correctOptionId: 'fila',
  ),
  QuizQuestion(
    id: 'nivelamento-02', order: 2,
    statement: 'Qual canal permite automações e vários atendentes no mesmo número?',
    options: [
      QuizOption(id: 'app', text: 'WhatsApp app comum'),
      QuizOption(id: 'api', text: 'WhatsApp Business API oficial'),
      QuizOption(id: 'sms', text: 'SMS'),
    ],
    correctOptionId: 'api',
  ),
];

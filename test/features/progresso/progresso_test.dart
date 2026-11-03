import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natyapp/core/error/failure.dart';
import 'package:natyapp/features/progresso/domain/resumo_conclusao.dart';
import 'package:natyapp/features/progresso/domain/resumo_progresso.dart';
import 'package:natyapp/features/progresso/presentation/bloc/conclusao_bloc.dart';
import 'package:natyapp/features/progresso/presentation/bloc/conclusao_event.dart';
import 'package:natyapp/features/progresso/presentation/bloc/progresso_bloc.dart';
import 'package:natyapp/features/progresso/presentation/bloc/progresso_event.dart';
import 'package:natyapp/features/progresso/presentation/mensagens_erro.dart';
import 'package:natyapp/features/progresso/presentation/pages/conclusao.dart';
import 'package:natyapp/features/progresso/presentation/pages/progresso.dart';

import 'dados_de_teste.dart';

Widget _app(Widget pagina) => MaterialApp(home: Scaffold(body: pagina));

Widget _paginaProgresso(RepositorioFake repositorio) => _app(
  BlocProvider(
    create: (_) => ProgressoBloc(repositorio)..add(const ProgressoSolicitado()),
    child: const ProgressoPage(),
  ),
);

Widget _paginaConclusao(RepositorioFake repositorio) => _app(
  BlocProvider(
    create: (_) => ConclusaoBloc(repositorio)..add(const ConclusaoSolicitada()),
    child: const ConclusaoPage(),
  ),
);

void main() {
  group('ResumoProgresso', () {
    test('calcula o XP que falta e o avanço dentro do nível', () {
      expect(resumoDeTeste.xpParaProximoNivel, 160);
      expect(resumoDeTeste.progressoNoNivel, closeTo(0.2, 0.0001));
    });
  });

  group('ResumoConclusao', () {
    test('extrai primeiro nome e iniciais', () {
      expect(conclusaoDeTeste.primeiroNome, 'Marina');
      expect(conclusaoDeTeste.iniciais, 'MR');
    });
  });

  group('leitura do JSON da API', () {
    test('lê o resumo de progresso', () {
      final resumo = ResumoProgresso.fromJson({
        'xpTotal': 240,
        'nivel': 2,
        'nomeNivel': 'Operador',
        'xpInicioNivel': 200,
        'xpProximoNivel': 400,
        'diasSeguidos': 4,
        'percentualAcertoQuiz': 92,
        'trilhasConcluidas': 1,
        'totalTrilhas': 3,
        'conquistas': [
          {
            'codigo': 'QUIZ_SEM_ERRO',
            'titulo': 'Quiz sem erro',
            'conquistada': true,
            'pendencia': null,
          },
          {
            'codigo': 'CODIGO_NOVO_DO_BACK',
            'titulo': 'Conquista nova',
            'conquistada': false,
            'pendencia': 'Falta 1 trilha',
          },
        ],
      });

      expect(resumo.xpTotal, 240);
      expect(resumo.xpParaProximoNivel, 160);
      expect(resumo.conquistas.first.tipo, TipoConquista.quizSemErro);
      expect(resumo.conquistas.last.tipo, TipoConquista.outra);
      expect(resumo.conquistas.last.pendencia, 'Falta 1 trilha');
    });

    test('lê o selo de conclusão', () {
      final conclusao = ResumoConclusao.fromJson({
        'nomeIntegrante': 'Marina Rocha',
        'numeroSelo': 412,
        'trilhasConcluidas': 3,
        'totalTrilhas': 3,
        'quizzesRealizados': 9,
        'percentualAcertoQuiz': 92,
        'itensConfiguracao': 14,
        'emitidoEm': '2026-08-14T12:00:00Z',
      });

      expect(conclusao.iniciais, 'MR');
      expect(conclusao.numeroSelo, 412);
      expect(conclusao.emitidoEm.toUtc(), DateTime.utc(2026, 8, 14, 12));
    });

    test('recusa JSON com campo faltando', () {
      expect(
        () => ResumoConclusao.fromJson({'nomeIntegrante': 'Marina'}),
        throwsFormatException,
      );
    });
  });

  group('mensagens de erro', () {
    String progresso(Object erro) =>
        mensagemDeErro(erro, tela: TelaDoErro.progresso);
    String conclusao(Object erro) =>
        mensagemDeErro(erro, tela: TelaDoErro.conclusao);

    test('sem conexão', () {
      expect(progresso(const NetworkFailure()), contains('Sem conexão'));
    });

    test('sessão expirada', () {
      expect(
        progresso(const ApiFailure(status: 401)),
        contains('sessão expirou'),
      );
    });

    test('sem permissão fala do que a pessoa tentava ver', () {
      expect(
        progresso(const ApiFailure(status: 403)),
        contains('seu progresso'),
      );
      expect(
        conclusao(const ApiFailure(status: 403)),
        contains('seu selo de conclusão'),
      );
    });

    test('selo ainda não emitido, pelo código ou pelo 404', () {
      const pendente = 'Você ainda não concluiu a implantação';
      expect(
        conclusao(
          const ApiFailure(status: 409, codigo: codigoConclusaoNaoEmitida),
        ),
        contains(pendente),
      );
      expect(conclusao(const ApiFailure(status: 404)), contains(pendente));
      expect(
        progresso(const ApiFailure(status: 404)),
        isNot(contains(pendente)),
      );
    });

    test('servidor fora do ar', () {
      expect(conclusao(const ApiFailure(status: 503)), contains('instável'));
    });

    test('resposta fora do contrato', () {
      expect(
        progresso(const FormatException('campo xpTotal')),
        contains('dados inesperados'),
      );
    });

    test('qualquer outro erro vira uma mensagem genérica', () {
      expect(
        progresso(StateError('x')),
        'Não foi possível carregar seu progresso. Tente de novo.',
      );
    });
  });

  test('formata a data no padrão do design', () {
    expect(formatarDataCurta(DateTime(2026, 8, 14)), '14 ago 2026');
  });

  group('ProgressoPage', () {
    testWidgets('mostra XP, nível, indicadores e conquistas', (tester) async {
      await tester.pumpWidget(_paginaProgresso(RepositorioFake()));
      await tester.pumpAndSettle();

      expect(find.text('240'), findsOneWidget);
      expect(find.text('NÍVEL 2 · Operador'), findsOneWidget);
      expect(find.text('160 XP para o próximo nível'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('1/3'), findsOneWidget);
      expect(find.text('Primeiro canal'), findsOneWidget);
      expect(find.text('Conquistada'), findsNWidgets(3));
      expect(find.text('Faltam 2 trilhas'), findsOneWidget);
      expect(find.text('Voltar para a home'), findsOneWidget);
    });

    testWidgets('mostra a falha amigável e recarrega ao tentar novamente', (
      tester,
    ) async {
      final repositorio = RepositorioFake(erro: const NetworkFailure());
      await tester.pumpWidget(_paginaProgresso(repositorio));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sem conexão'), findsOneWidget);

      repositorio.erro = null;
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('240'), findsOneWidget);
    });

    testWidgets('puxar para baixo busca os dados de novo', (tester) async {
      final repositorio = RepositorioFake();
      await tester.pumpWidget(_paginaProgresso(repositorio));
      await tester.pumpAndSettle();
      expect(repositorio.chamadasResumo, 1);

      await tester.fling(find.text('240'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(repositorio.chamadasResumo, 2);
      expect(find.text('240'), findsOneWidget);
    });

    testWidgets('falha ao atualizar mantém os dados e avisa', (tester) async {
      final repositorio = RepositorioFake();
      await tester.pumpWidget(_paginaProgresso(repositorio));
      await tester.pumpAndSettle();

      repositorio.erro = const ApiFailure(status: 503);
      await tester.fling(find.text('240'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(find.text('240'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('instável'), findsOneWidget);
    });
  });

  group('ConclusaoPage', () {
    testWidgets('mostra saudação, selo e próximos passos', (tester) async {
      await tester.pumpWidget(_paginaConclusao(RepositorioFake()));
      await tester.pumpAndSettle();

      expect(find.text('Olá, Marina'), findsOneWidget);
      expect(find.text('Implantação concluída'), findsOneWidget);
      expect(find.text('MR'), findsOneWidget);
      expect(find.text('Nº 0412'), findsOneWidget);
      expect(find.text('3 de 3'), findsOneWidget);
      expect(find.text('9 · 92%'), findsOneWidget);
      expect(find.text('14 ago 2026'), findsOneWidget);
      expect(find.text('Falar com a Naty'), findsOneWidget);

      await tester.tap(find.text('Compartilhar selo'));
      await tester.pump();
      expect(find.text('Em breve'), findsOneWidget);
    });

    testWidgets('selo não emitido mostra o que falta fazer', (tester) async {
      final repositorio = RepositorioFake(
        erro: const ApiFailure(status: 404, codigo: codigoConclusaoNaoEmitida),
      );
      await tester.pumpWidget(_paginaConclusao(repositorio));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Você ainda não concluiu a implantação'),
        findsOneWidget,
      );
    });
  });
}

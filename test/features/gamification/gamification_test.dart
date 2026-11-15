import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natyapp/core/config/app_config.dart';
import 'package:natyapp/core/network/api_client.dart';
import 'package:natyapp/features/gamification/data/gamification_repository.dart';
import 'package:natyapp/features/gamification/domain/gamification.dart';
import 'package:natyapp/features/gamification/presentation/gamification_panel.dart';
import 'package:natyapp/features/gamification/presentation/ranking_view.dart';
import 'package:natyapp/features/gamification/presentation/streak_flame.dart';
import 'gamification_fixtures.dart';

class _Api extends ApiClient {
  _Api() : super(AppConfig.development);
  final paths = <String>[];
  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    paths.add(path);
    if (path.contains('/ranking')) {
      return {
        'itens': [],
        'pagina': 1,
        'tamanho': 20,
        'totalItens': 21,
        'totalPaginas': 2,
      };
    }
    return summaryJson();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final root = Platform.environment['FLUTTER_ROOT']!;
    for (final entry in {
      'Roboto': 'Roboto-Regular.ttf',
      'MaterialIcons': 'MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(entry.key)..addFont(
            File(
              '$root/bin/cache/artifacts/material_fonts/${entry.value}',
            ).readAsBytes().then(ByteData.sublistView),
          ))
          .load();
    }
  });

  Widget panel(FakeGamificationRepository repo, {int revision = 0}) =>
      MaterialApp(
        theme: ThemeData.dark(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: SingleChildScrollView(
              child: GamificationPanel(
                repository: repo,
                memberId: 'member-1',
                revision: revision,
              ),
            ),
          ),
        ),
      );

  test(
    'DTO usa números reais e calcula XP restante a partir da faixa inteira',
    () {
      final summary = Gamification.fromJson(summaryJson(streak: 3));
      expect(summary.xpRemaining, 280);
      expect(summary.currentStreak, 3);
      expect(summary.lastActiveDate!.day, 15);
      expect(summary.quizzes.accuracy, 90.5);
      expect(summary.achievements.first.code, 'PRIMEIRA_ATIVIDADE');
      final empty = Gamification.fromJson(summaryJson(empty: true));
      expect(empty.quizzes.bestScore, isNull);
      expect(empty.achievements, isEmpty);
      expect(empty.level, 1);
      expect(
        () => Gamification.fromJson({'integranteId': 'member-1'}),
        throwsFormatException,
      );
    },
  );

  test(
    'repositório usa ID da sessão e paginação configurada no backend',
    () async {
      final api = _Api();
      final repo = GamificationRepositoryApi(api);
      await repo.fetchSummary('member-1');
      final page = await repo.fetchRanking(page: 1);
      expect(api.paths, [
        '/api/v1/integrantes/member-1/gamificacao',
        '/api/v1/ranking?pagina=1&tamanho=20',
      ]);
      expect(page.hasMore, isFalse);
    },
  );

  testWidgets('perfil mostra XP nível estatísticas e conquistas da API', (
    tester,
  ) async {
    final repo = FakeGamificationRepository();
    await tester.binding.setSurfaceSize(const Size(390, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(panel(repo));
    await tester.pumpAndSettle();
    expect(repo.summaryIds, ['member-1']);
    expect(find.text('120 XP'), findsOneWidget);
    expect(find.text('Nível 2'), findsOneWidget);
    expect(find.text('280 XP para o nível 3'), findsOneWidget);
    expect(find.text('90,5%'), findsOneWidget);
    expect(find.text('Acerto perfeito'), findsOneWidget);
    await expectLater(
      find.byType(GamificationPanel),
      matchesGoldenFile('goldens/gamification.png'),
    );
    repo.summary = Gamification.fromJson(summaryJson(xp: 150));
    await tester.pumpWidget(panel(repo, revision: 1));
    await tester.pumpAndSettle();
    expect(find.text('150 XP'), findsOneWidget);
    repo.failSummary = true;
    await tester.pumpWidget(panel(repo, revision: 2));
    await tester.pumpAndSettle();
    expect(find.text('150 XP'), findsOneWidget);
    expect(
      find.text('Não foi possível atualizar sua evolução.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'novo integrante sem quizzes ou conquistas não recebe números inventados',
    (tester) async {
      final repo = FakeGamificationRepository()
        ..summary = Gamification.fromJson(summaryJson(empty: true));
      await tester.pumpWidget(panel(repo));
      await tester.pumpAndSettle();
      expect(find.text('0 XP'), findsOneWidget);
      expect(
        find.text('Você ainda não respondeu nenhum quiz.'),
        findsOneWidget,
      );
      expect(
        find.text('Conclua atividades para conquistar seus primeiros marcos.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('ranking pagina sem duplicar e preserva a lista após falha', (
    tester,
  ) async {
    final repo = FakeGamificationRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: RankingView(repository: repo, memberId: 'member-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Marina Rocha · Você'), findsOneWidget);
    repo.failRanking = true;
    await tester.tap(find.text('Carregar mais'));
    await tester.pumpAndSettle();
    expect(find.text('Marina Rocha · Você'), findsOneWidget);
    expect(find.text('Não foi possível carregar o ranking.'), findsOneWidget);
    repo.failRanking = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(repo.pages, [0, 1, 1]);
    expect(find.text('Rafael Silva'), findsOneWidget);
    expect(find.byKey(const ValueKey('ranking-member-1')), findsOneWidget);
    expect(find.text('Carregar mais'), findsNothing);
  });

  testWidgets('chamas se movem ao redor do ícone e param fora da tela', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            controller: controller,
            children: const [
              Align(child: StreakFlame(active: true)),
              SizedBox(height: 1600),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 300));
    final painters = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .where((item) => item.painter is StreakFirePainter);
    expect(painters, isNotEmpty);
    final phase = (painters.first.painter as StreakFirePainter).phase;
    await tester.pump(const Duration(milliseconds: 300));
    final next = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .firstWhere((item) => item.painter is StreakFirePainter);
    expect((next.painter as StreakFirePainter).phase, isNot(phase));
    await expectLater(
      find.descendant(of: find.byType(StreakFlame), matching: find.byType(RepaintBoundary)).first,
      matchesGoldenFile('goldens/streak_fire.png'),
    );
    controller.jumpTo(1000);
    await tester.pump();
    await tester.pump();
    expect(
      tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((item) => item.painter is StreakFirePainter),
      isEmpty,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('fogo respeita redução de movimento e sequência zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: StreakFlame(active: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((item) => item.painter is StreakFirePainter),
      isEmpty,
    );
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
  });
}

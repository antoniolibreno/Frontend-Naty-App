import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natyapp/features/gamification/domain/gamification.dart';
import 'package:natyapp/features/gamification/presentation/ranking_podium.dart';
import 'package:natyapp/features/gamification/presentation/ranking_view.dart';
import 'gamification_fixtures.dart';

const topFive = [
  RankingEntry(
    memberId: 'one',
    name: 'Marina Rocha',
    position: 1,
    totalXp: 940,
    level: 4,
    currentStreak: 7,
  ),
  RankingEntry(
    memberId: 'two',
    name: 'Rafael Silva',
    position: 2,
    totalXp: 800,
    level: 3,
    currentStreak: 6,
  ),
  RankingEntry(
    memberId: 'three',
    name: 'Camila Santos',
    position: 3,
    totalXp: 650,
    level: 3,
    currentStreak: 4,
  ),
  RankingEntry(
    memberId: 'four',
    name: 'Lucas Pereira',
    position: 4,
    totalXp: 420,
    level: 3,
    currentStreak: 3,
  ),
  RankingEntry(
    memberId: 'five',
    name: 'Ana Costa',
    position: 5,
    totalXp: 300,
    level: 2,
    currentStreak: 2,
  ),
];

class _Repository extends FakeGamificationRepository {
  final sizes = <int>[];
  @override
  Future<RankingPage> fetchRanking({int page = 0, int size = 20}) async {
    pages.add(page);
    sizes.add(size);
    if (failRanking) throw Exception('Falha simulada');
    return const RankingPage(
      items: topFive,
      page: 0,
      size: 5,
      totalItems: 5,
      totalPages: 1,
    );
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

  Future<void> mount(
    WidgetTester tester,
    _Repository repo, {
    double width = 390,
    double scale = 1,
    bool reduced = false,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(scale),
            disableAnimations: reduced,
          ),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topCenter,
                child: RankingPodium(repository: repo, memberId: 'one'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'top cinco ficam lado a lado e três pontos abrem ranking completo',
    (tester) async {
      final repo = _Repository();
      await mount(tester, repo);
      expect(repo.sizes, [5]);
      expect(find.textContaining('Ver ranking'), findsNothing);
      for (var position = 1; position <= 5; position++) {
        expect(find.byKey(ValueKey('pedestal-$position')), findsOneWidget);
      }
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('pedestal-4'))).dx,
        lessThan(
          tester.getTopLeft(find.byKey(const ValueKey('pedestal-2'))).dx,
        ),
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('pedestal-1'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const ValueKey('pedestal-2'))).dy,
        ),
      );
      await expectLater(
        find.byType(RankingPodium),
        matchesGoldenFile('goldens/top_five_podium.png'),
      );
      await tester.tap(find.byKey(const ValueKey('ranking-options')));
      await tester.pumpAndSettle();
      expect(find.byType(RankingView), findsOneWidget);
      expect(repo.sizes, [5, 20]);
      expect(find.text('Marina Rocha · Você'), findsOneWidget);
    },
  );

  testWidgets('pódio acomoda texto ampliado em largura compacta', (
    tester,
  ) async {
    await mount(tester, _Repository(), width: 320, scale: 1.6);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(RankingPodium),
      matchesGoldenFile('goldens/top_five_podium_large_text.png'),
    );
  });

  testWidgets('pedestais sobem e redução de movimento mostra altura final', (
    tester,
  ) async {
    Widget app(bool reduced) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: RankingPodiumBars(entries: topFive, memberId: 'one'),
        ),
      ),
    );
    await tester.pumpWidget(app(false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 200));
    final middle = tester
        .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .map((widget) => widget.heightFactor!)
        .toList();
    expect(middle.any((value) => value > 0 && value < 1), isTrue);
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .every((widget) => widget.heightFactor == 1),
      isTrue,
    );
    await tester.pumpWidget(app(true));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .every((widget) => widget.heightFactor == 1),
      isTrue,
    );
  });

  testWidgets(
    'falha ao atualizar preserva o pódio e acesso pelos três pontos',
    (tester) async {
      final repo = _Repository();
      Widget app(int revision) => MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: RankingPodium(
            repository: repo,
            memberId: 'one',
            revision: revision,
          ),
        ),
      );
      await tester.pumpWidget(app(0));
      await tester.pumpAndSettle();
      repo.failRanking = true;
      await tester.pumpWidget(app(1));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pedestal-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('pedestal-5')), findsOneWidget);
      expect(find.text('Atualizar pódio'), findsOneWidget);
      expect(find.byKey(const ValueKey('ranking-options')), findsOneWidget);
    },
  );
}

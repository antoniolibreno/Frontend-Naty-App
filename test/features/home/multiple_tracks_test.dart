import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natyapp/core/components/learning_path.dart';
import 'package:natyapp/core/components/completion_water_fill.dart';
import 'package:natyapp/core/components/track_milestone.dart';
import 'package:natyapp/core/widgets/learning_path_loading.dart';
import 'package:natyapp/core/di/injection.dart';
import 'package:natyapp/features/home/presentation/pages/home.dart';
import 'package:natyapp/features/training/data/training_repository_api.dart';
import 'package:natyapp/features/training/domain/training.dart';

class _Repository implements TrainingRepository {
  bool completed = false;
  bool longTitles = false;
  int lessonCount = 1;
  Completer<void>? gate;
  bool fail = false;
  final queried = <String>[];

  @override
  Future<List<TrainingTrack>> fetchTracks() async {
    await gate?.future;
    if (fail) throw StateError('Falha simulada');
    return [
      TrainingTrack(
        id: 'first',
        title: longTitles
            ? 'Primeiros passos na organização do atendimento da sua empresa'
            : 'Primeiros passos',
      ),
      TrainingTrack(
        id: 'second',
        title: longTitles
            ? 'Configuração dos canais e distribuição das conversas de atendimento'
            : 'Atendimento',
      ),
      const TrainingTrack(id: 'third', title: 'Automações'),
    ];
  }

  @override
  Future<TrainingProgress> fetchProgress(String trackId) async {
    queried.add(trackId);
    return TrainingProgress(
      trackId: trackId,
      completed: trackId == 'first' && completed ? 1 : 0,
      total: 1,
      activities: [
        for (var index = 0; index < lessonCount; index++)
          TrainingProgressActivity(
            id: '$trackId-lesson-$index',
            title: 'Aula $trackId',
            description: '',
            state: trackId == 'first' && completed ? 'CONCLUIDO' : 'DISPONIVEL',
          ),
      ],
    );
  }

  @override
  Future<TrainingActivity> fetchActivity(String activityId) async =>
      throw UnimplementedError();
  @override
  Future<void> registerVideoStarted(String activityId) async {}
  @override
  Future<void> registerVideoWatched(String activityId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final root = Platform.environment['FLUTTER_ROOT']!;
    for (final entry in {
      'Roboto': 'Roboto-Regular.ttf',
      'MaterialIcons': 'MaterialIcons-Regular.otf',
    }.entries) {
      final font = FontLoader(entry.key)
        ..addFont(
          File(
            '$root/bin/cache/artifacts/material_fonts/${entry.value}',
          ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
      await font.load();
    }
  });
  late _Repository repository;
  setUp(() async {
    await getIt.reset();
    repository = _Repository();
    getIt.registerSingleton<TrainingRepository>(repository);
  });
  tearDown(() async {
    await getIt.reset();
  });

  Future<void> mount(WidgetTester tester, {double width = 390}) async {
    await tester.binding.setSurfaceSize(Size(width, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(body: HomePage(color: Colors.purple)),
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                repository.completed = true;
                Navigator.of(context).pop();
              },
              child: const Text('Concluir aula'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'consulta todas as trilhas e mantém futuras visíveis e bloqueadas',
    (tester) async {
      await mount(tester);
      expect(repository.queried, ['first', 'second', 'third']);
      expect(find.text('Primeiros passos'), findsOneWidget);
      expect(find.text('Atendimento'), findsOneWidget);
      expect(find.text('Automações'), findsOneWidget);
      final paths = tester
          .widgetList<LearningPath>(find.byType(LearningPath))
          .toList();
      expect(paths[0].steps.single.onTap, isNotNull);
      expect(paths[1].steps.single.state, LearningPathStepState.locked);
      expect(paths[1].steps.single.onTap, isNull);
      expect(paths[2].steps.single.onTap, isNull);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(HomePage),
        matchesGoldenFile('goldens/multiple_tracks.png'),
      );
    },
  );

  testWidgets('conclusão recarrega e libera só a próxima trilha', (
    tester,
  ) async {
    await mount(tester);
    tester
        .widget<LearningPath>(find.byType(LearningPath).first)
        .steps
        .single
        .onTap!();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluir aula'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(CompletionWaterFill), findsOneWidget);
    expect(find.byType(TrackMilestone), findsNothing);
    for (
      var frame = 0;
      frame < 40 && find.byKey(const ValueKey('completed')).evaluate().isEmpty;
      frame++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const ValueKey('completed')), findsOneWidget);
    expect(find.byType(CompletionWaterFill), findsNothing);
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/track_completed.png'),
    );
    for (
      var frame = 0;
      frame < 20 && find.byKey(const ValueKey('unlocked')).evaluate().isEmpty;
      frame++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const ValueKey('completed')), findsNothing);
    expect(find.byKey(const ValueKey('unlocked')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/track_unlocked.png'),
    );
    await tester.pumpAndSettle();
    final paths = tester
        .widgetList<LearningPath>(find.byType(LearningPath))
        .toList();
    expect(paths[0].steps.single.state, LearningPathStepState.completed);
    expect(paths[1].steps.single.onTap, isNotNull);
    expect(paths[2].steps.single.onTap, isNull);
    expect(repository.queried.length, 6);
    expect(find.byType(CompletionWaterFill), findsNothing);
    expect(find.byType(TrackMilestone), findsNothing);
    tester
        .widget<LearningPath>(find.byType(LearningPath).first)
        .steps
        .single
        .onTap!();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluir aula'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(CompletionWaterFill), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('onda verde preenche o botão e finaliza uma única vez', (
    tester,
  ) async {
    var finished = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CompletionWaterFill(size: 96, onComplete: () => finished++),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 600));
    final paint = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .firstWhere((item) => item.painter is CompletionWaterPainter);
    expect(
      (paint.painter! as CompletionWaterPainter).progress,
      closeTo(.5, .05),
    );
    await expectLater(
      find.byType(CompletionWaterFill),
      matchesGoldenFile('goldens/completion_water_half.png'),
    );
    expect(finished, 0);
    await tester.pumpAndSettle();
    expect(finished, 1);
  });

  testWidgets('reduzir animações mostra imediatamente o botão concluído', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: CompletionWaterFill(size: 58)),
        ),
      ),
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(
      tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((item) => item.painter is CompletionWaterPainter),
      isEmpty,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('escala de texto cabe em tela compacta', (tester) async {
    await mount(tester, width: 320);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: const Scaffold(body: HomePage(color: Colors.purple)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/multiple_tracks_large_text.png'),
    );
  });

  testWidgets('título acompanha a rolagem e cede lugar à próxima trilha', (
    tester,
  ) async {
    repository.lessonCount = 8;
    await mount(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Primeiros passos')).dy, closeTo(16, 1));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -850));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Atendimento')).dy, closeTo(16, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'atualização mantém percurso e posição com barra de carregamento',
    (tester) async {
      repository.lessonCount = 8;
      await mount(tester);
      final scroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      scroll.position.jumpTo(80);
      repository.gate = Completer<void>();
      final refresh = tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();
      await tester.pump();
      expect(find.text('Primeiros passos'), findsOneWidget);
      expect(find.byKey(const ValueKey('tracks-refreshing')), findsOneWidget);
      expect(find.byType(LearningPathLoading), findsNothing);
      expect(scroll.position.pixels, 80);
      repository.gate!.complete();
      await refresh;
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('tracks-refreshing')), findsNothing);
      expect(scroll.position.pixels, 80);
    },
  );

  testWidgets('falha na atualização preserva dados e oferece nova tentativa', (
    tester,
  ) async {
    await mount(tester);
    repository.fail = true;
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();
    expect(find.text('Primeiros passos'), findsOneWidget);
    expect(
      find.text('Não foi possível atualizar suas trilhas.'),
      findsOneWidget,
    );
    repository.fail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível atualizar suas trilhas.'), findsNothing);
  });

  testWidgets('primeira carga mostra placeholder até os dados chegarem', (
    tester,
  ) async {
    repository.gate = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: const HomePage(color: Colors.purple)),
      ),
    );
    await tester.pump();
    expect(find.byType(LearningPathLoading), findsOneWidget);
    expect(find.byType(LearningPath), findsNothing);
    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LearningPathLoading), findsNothing);
    expect(find.text('Primeiros passos'), findsOneWidget);
  });

  testWidgets('histórico concluído abre sem repetir celebrações', (
    tester,
  ) async {
    repository.completed = true;
    await mount(tester);
    expect(find.byType(CompletionWaterFill), findsNothing);
    expect(find.byType(TrackMilestone), findsNothing);
    expect(find.text('Concluída'), findsOneWidget);
  });

  testWidgets(
    'cabeçalhos longos se medem sem overflow durante troca de seção',
    (tester) async {
      repository.longTitles = true;
      repository.lessonCount = 4;
      await mount(tester, width: 320);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
            child: const Scaffold(body: HomePage(color: Colors.purple)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var step = 0; step < 12; step++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );
}

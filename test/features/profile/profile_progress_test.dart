import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natyapp/core/auth/authenticated_user.dart';
import 'package:natyapp/core/config/app_config.dart';
import 'package:natyapp/core/network/api_client.dart';
import 'package:natyapp/features/profile/presentation/pages/profile.dart';
import 'package:natyapp/features/profile/domain/profile_overview.dart';
import 'package:natyapp/features/training/data/training_repository_api.dart';
import 'package:natyapp/features/training/domain/training.dart';
import '../gamification/gamification_fixtures.dart';
import 'package:natyapp/features/profile/data/profile_account_repository.dart';

class _AccountRepository implements ProfileAccountRepository {
  bool fail = false;
  AuthenticatedUser user = const AuthenticatedUser(
    name: 'Marina Rocha',
    email: 'marina@exemplo.com',
    userId: 'member-1',
    companyId: 'company-1',
    companyName: 'Empresa Exemplo',
    jobTitle: 'Supervisora de atendimento',
  );
  @override
  Future<AuthenticatedUser> fetchAccount() async {
    if (fail) throw Exception('Falha simulada');
    return user;
  }
}

class _ProfileApi extends ApiClient {
  _ProfileApi() : super(AppConfig.development);
  final paths = <String>[];
  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    paths.add(path);
    return {
      'id': 'member-1',
      'nome': 'Marina Atualizada',
      'email': 'marina@exemplo.com',
      'empresa': {'id': 'company-1', 'nome': 'Empresa Exemplo'},
      'cargo': 'Supervisora',
      'papel': 'INTEGRANTE',
    };
  }
}

class _Repository implements TrainingRepository {
  Completer<void>? gate;
  bool fail = false;
  @override
  Future<List<TrainingTrack>> fetchTracks() async {
    await gate?.future;
    if (fail) throw StateError('Falha de rede');
    return const [
      TrainingTrack(id: 'one', title: 'Primeiros passos'),
      TrainingTrack(id: 'two', title: 'Atendimento'),
      TrainingTrack(id: 'three', title: 'Automações'),
    ];
  }

  @override
  Future<TrainingProgress> fetchProgress(String id) async => TrainingProgress(
    trackId: id,
    total: 2,
    completed: id == 'one'
        ? 2
        : id == 'two'
        ? 1
        : 0,
  );
  @override
  Future<TrainingActivity> fetchActivity(String id) async =>
      throw UnimplementedError();
  @override
  Future<void> registerVideoStarted(String id) async {}
  @override
  Future<void> registerVideoWatched(String id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const identity = AuthenticatedUser(
    name: 'Marina Rocha',
    email: 'marina@exemplo.com',
    userId: 'member-1',
  );
  setUpAll(() async {
    final root = Platform.environment['FLUTTER_ROOT']!;
    for (final entry in {
      'Roboto': 'Roboto-Regular.ttf',
      'MaterialIcons': 'MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(
          File(
            '$root/bin/cache/artifacts/material_fonts/${entry.value}',
          ).readAsBytes().then(ByteData.sublistView),
        );
      await loader.load();
    }
  });

  Future<void> mount(
    WidgetTester tester,
    _Repository repository, {
    double width = 390,
    double scale = 1,
    ProfileAccountRepository? account,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: ProfilePage(
            repository: repository,
            identity: identity,
            gamificationRepository: FakeGamificationRepository(),
            accountRepository: account ?? _AccountRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('resumo agrega aulas e trilhas e identifica a trilha atual', () async {
    final repo = _Repository();
    final tracks = await repo.fetchTracks();
    final data = ProfileOverview(
      TrainingSection.sequence(
        tracks,
        await Future.wait(tracks.map((track) => repo.fetchProgress(track.id))),
      ),
    );
    expect(data.completedLessons, 3);
    expect(data.totalLessons, 6);
    expect(data.completedTracks, 1);
    expect(data.progress, .5);
    expect(data.currentTrack!.track.id, 'two');
    expect(const ProfileOverview([]).progress, 0);
  });

  test('sessão guarda identidade do login e limpa ao sair', () {
    final api = ApiClient(AppConfig.development);
    api.setSession({
      'nome': identity.name,
      'email': identity.email,
      'token': 'test-only',
      'usuarioId': 'member-1',
    });
    expect(api.currentUser!.name, identity.name);
    expect(api.currentUser!.initials, 'MR');
    expect(api.currentUser!.userId, 'member-1');
    api.clearToken();
    expect(api.currentUser, isNull);
  });

  testWidgets(
    'perfil apresenta sessão, progresso consolidado e todas as trilhas',
    (tester) async {
      await mount(tester, _Repository());
      expect(find.text(identity.name), findsOneWidget);
      expect(find.text(identity.email), findsOneWidget);
      expect(find.text('3/6'), findsOneWidget);
      expect(find.text('1/3'), findsOneWidget);
      expect(find.text('Trilha atual'), findsOneWidget);
      await expectLater(
        find.byType(ProfilePage),
        matchesGoldenFile('goldens/profile_progress.png'),
      );
      await tester.scrollUntilVisible(find.text('Evolução'), 300);
      await tester.pumpAndSettle();
      expect(find.text('XP total'), findsOneWidget);
      expect(find.text('Nível 2'), findsOneWidget);
      expect(find.text('120 XP'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Conquistas'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Conquistas'), findsOneWidget);
      expect(find.text('240 XP'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('perfil acomoda texto ampliado em largura compacta', (
    tester,
  ) async {
    await mount(tester, _Repository(), width: 320, scale: 1.5);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(ProfilePage),
      matchesGoldenFile('goldens/profile_large_text.png'),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -850));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('falha conserva progresso no perfil e permite nova tentativa', (
    tester,
  ) async {
    final repo = _Repository();
    await mount(tester, repo);
    repo.fail = true;
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();
    expect(find.text('3/6'), findsOneWidget);
    expect(
      find.text('Não foi possível atualizar seu progresso.'),
      findsOneWidget,
    );
    repo.fail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível atualizar seu progresso.'),
      findsNothing,
    );
  });

  testWidgets('barra anima até o valor real e acompanha atualizações', (
    tester,
  ) async {
    Widget app(double value) => MaterialApp(
      home: Scaffold(
        body: ProfileProgressBar(value: value, label: 'Progresso'),
      ),
    );
    await tester.pumpWidget(app(.5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 100));
    final during = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
        .value!;
    expect(during, greaterThan(0));
    expect(during, lessThan(.5));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      closeTo(.5, .001),
    );
    await tester.pumpWidget(app(.8));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      closeTo(.8, .001),
    );
  });

  testWidgets('redução de movimento exibe valor final sem animação', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: ProfileProgressBar(value: .5, label: 'Progresso'),
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      .5,
    );
    await tester.pumpAndSettle();
  });

  test(
    'perfil usa usuarios/me e atualiza identidade sem trocar sessão',
    () async {
      final api = _ProfileApi();
      api.setSession({
        'usuarioId': 'member-1',
        'nome': 'Marina Antiga',
        'email': 'marina@exemplo.com',
        'token': 'test-only',
      });
      final user = await ProfileAccountRepositoryApi(api).fetchAccount();
      expect(api.paths, ['/api/v1/usuarios/me']);
      expect(user.companyName, 'Empresa Exemplo');
      expect(user.jobTitle, 'Supervisora');
      expect(api.currentUser!.name, 'Marina Atualizada');
    },
  );

  testWidgets('perfil atualiza nome empresa e cargo e conserva após falha', (
    tester,
  ) async {
    final account = _AccountRepository()
      ..user = const AuthenticatedUser(
        name: 'Marina Atualizada',
        email: 'marina@exemplo.com',
        userId: 'member-1',
        companyId: 'company-1',
        companyName: 'Empresa Exemplo',
        jobTitle: 'Supervisora de atendimento',
      );
    await mount(tester, _Repository(), account: account);
    expect(find.text('Marina Atualizada'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sobre você'), 500);
    await tester.pumpAndSettle();
    expect(find.text('Empresa Exemplo'), findsOneWidget);
    expect(find.text('Supervisora de atendimento'), findsOneWidget);
    account.fail = true;
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Sobre você'), 300);
    await tester.pumpAndSettle();
    expect(find.text('Empresa Exemplo'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Não foi possível atualizar seus dados.'),
      -500,
    );
    await tester.pumpAndSettle();
    expect(find.text('Atualizar dados do perfil'), findsOneWidget);
  });
}

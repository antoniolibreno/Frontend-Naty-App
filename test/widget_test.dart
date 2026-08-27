import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:natyapp/app/app.dart';
import 'package:natyapp/core/config/app_config.dart';
import 'package:natyapp/core/di/injection.dart';
import 'package:natyapp/core/router/app_router.dart';
import 'package:natyapp/core/router/app_routes.dart';

void main() {
  testWidgets('renderiza a casca inicial da aplicação', (
    WidgetTester tester,
  ) async {
    configureDependencies();
    await tester.pumpWidget(
      const NatyApp(config: AppConfig.development, router: AppRouter()),
    );

    expect(find.byType(NatyApp), findsOneWidget);
  });

  testWidgets('oculta a navegação global no login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoute.login.path,
        onGenerateRoute: const AppRouter().generateRoute,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('exibe ícones em telas compactas', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoute.home.path,
        onGenerateRoute: const AppRouter().generateRoute,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Início'), findsOneWidget);
    expect(find.byTooltip('Perfil'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('exibe ícones em telas largas', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 844));
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoute.home.path,
        onGenerateRoute: const AppRouter().generateRoute,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Início'), findsOneWidget);
    expect(find.byTooltip('Perfil'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });
}

// Testes de imagem (golden): guardam uma "foto" das telas em tamanho de
// celular e falham se o visual mudar sem querer.
//
// Para gerar ou atualizar as imagens de referência (depois de uma mudança
// visual intencional), rode:
//   flutter test --update-goldens test/features/progresso/progresso_golden_test.dart
//
// As imagens ficam em test/features/progresso/goldens/ e devem ir no commit.
// O Flutter usa nos testes uma fonte de blocos no lugar do texto, então a
// imagem confere layout, cores, espaçamentos e ícones, não a fonte.
// A renderização varia um pouco entre sistemas: gere as referências no mesmo
// sistema em que os testes vão rodar.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natyapp/features/progresso/presentation/bloc/conclusao_bloc.dart';
import 'package:natyapp/features/progresso/presentation/bloc/conclusao_event.dart';
import 'package:natyapp/features/progresso/presentation/bloc/progresso_bloc.dart';
import 'package:natyapp/features/progresso/presentation/bloc/progresso_event.dart';
import 'package:natyapp/features/progresso/presentation/pages/conclusao.dart';
import 'package:natyapp/features/progresso/presentation/pages/progresso.dart';

import 'dados_de_teste.dart';

/// Tamanho de tela do protótipo (iPhone de 393 x 852 pontos).
const _tamanhoDoCelular = Size(393, 852);

void _usarTelaDeCelular(WidgetTester tester) {
  tester.view.physicalSize = _tamanhoDoCelular;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _app(Widget pagina) => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(body: pagina),
);

void main() {
  testWidgets('Seu progresso', (tester) async {
    _usarTelaDeCelular(tester);
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) =>
              ProgressoBloc(RepositorioFake())
                ..add(const ProgressoSolicitado()),
          child: const ProgressoPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ProgressoPage),
      matchesGoldenFile('goldens/progresso.png'),
    );
  });

  testWidgets('Implantação concluída', (tester) async {
    _usarTelaDeCelular(tester);
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) =>
              ConclusaoBloc(RepositorioFake())
                ..add(const ConclusaoSolicitada()),
          child: const ConclusaoPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ConclusaoPage),
      matchesGoldenFile('goldens/conclusao.png'),
    );
  });
}

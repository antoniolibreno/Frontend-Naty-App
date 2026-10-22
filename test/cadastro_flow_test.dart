import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:natyapp/features/cadastro/cadastro_flow.dart';
import 'package:natyapp/features/cadastro/inicio_page.dart';

void main() {
  // Evita baixar fontes da internet durante os testes.
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('fluxo de cadastro abre na tela de início', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CadastroFlow()));

    expect(find.byType(InicioPage), findsOneWidget);
  });
}

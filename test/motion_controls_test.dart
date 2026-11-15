import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natyapp/core/widgets/press_feedback.dart';
import 'package:natyapp/core/widgets/learning_path_loading.dart';

void main() {
  testWidgets('toque comprime o botão, soltar restaura e aciona uma vez', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PressFeedback(
              child: SizedBox(
                width: 200,
                height: 56,
                child: TextButton(
                  onPressed: () => taps++,
                  child: const Text('Continuar'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.byType(TextButton);
    final initial = tester.getTopLeft(button);
    final gesture = await tester.startGesture(tester.getCenter(button));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.getTopLeft(button).dx, greaterThan(initial.dx));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(button).dx, closeTo(initial.dx, .01));
    expect(taps, 1);
  });

  testWidgets('toque cancelado não aciona o botão nem mantém compressão', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PressFeedback(
              child: TextButton(
                onPressed: () => taps++,
                child: const Text('Continuar'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.byType(TextButton);
    final initial = tester.getTopLeft(button);
    final gesture = await tester.startGesture(tester.getCenter(button));
    await tester.pump(const Duration(milliseconds: 150));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(taps, 0);
    expect(tester.getTopLeft(button).dx, closeTo(initial.dx, .01));
  });

  testWidgets('redução de movimento mantém botão e carregamento estáticos', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Column(
              children: [
                const LoadingProgressBar(label: 'Carregando'),
                PressFeedback(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Continuar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.byType(TextButton);
    final initial = tester.getTopLeft(button);
    final gesture = await tester.startGesture(tester.getCenter(button));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getTopLeft(button), initial);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await gesture.up();
    await tester.pumpAndSettle();
  });
}

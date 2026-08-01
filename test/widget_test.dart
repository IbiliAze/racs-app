import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:racs_reader/common/widgets/app_button.dart';

void main() {
  testWidgets('RACS action button handles taps', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(label: 'Scan card', onPressed: () => tapCount++),
        ),
      ),
    );

    expect(find.text('Scan card'), findsOneWidget);
    await tester.tap(find.text('Scan card'));
    expect(tapCount, 1);
  });
}

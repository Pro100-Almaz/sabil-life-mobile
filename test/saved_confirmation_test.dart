import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/shared/widgets/saved_confirmation.dart';

void main() {
  testWidgets('saved confirmation is compact and interactive', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedConfirmationBanner(
            message: 'Saved to favorites',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('Saved to favorites'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.byType(SavedConfirmationBanner));
    expect(tapped, isTrue);
  });
}

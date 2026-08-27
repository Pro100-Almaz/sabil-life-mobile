import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/data/models/listing.dart';
import 'package:sabil_life/features/map/widgets/category_map_marker.dart';

void main() {
  test('every listing category has a distinct map icon', () {
    final icons = CategoryType.values.map((category) => category.mapIcon);

    expect(icons.toSet(), hasLength(CategoryType.values.length));
  });

  testWidgets('selected marker uses the emphasized size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CategoryMapMarker(category: CategoryType.schools, selected: true),
      ),
    );

    final marker = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(marker.constraints?.maxWidth, 40);
    expect(find.byIcon(Icons.school_rounded), findsOneWidget);
  });
}

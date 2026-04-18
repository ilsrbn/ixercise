import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/features/home/home_overview_screen.dart';

void main() {
  testWidgets('home overview renders plans and does not show calories', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeOverviewScreen(),
        ),
      ),
    );

    expect(find.text('Calories'), findsNothing);
    expect(find.text('Nothing scheduled.'), findsOneWidget);
    expect(find.textContaining('No trainings yet.'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/design_system/ix_button.dart';

void main() {
  testWidgets('primary IxButton renders accent background', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IxButton.primary(label: 'Go'),
        ),
      ),
    );

    final Container container = tester.widget<Container>(
      find.byKey(const Key('ix_button_primary_container')),
    );
    final BoxDecoration decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, isNotNull);
  });
}

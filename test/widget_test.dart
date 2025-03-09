// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deeptalk/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Baue die App und triggere ein Frame
    await tester.pumpWidget(MyApp()); // Stelle sicher, dass `MyApp` korrekt importiert ist

    // Überprüfe, ob der Zähler bei 0 startet
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tippe auf das "+"-Symbol und triggere erneut ein Frame
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Überprüfe, ob der Zähler inkrementiert wurde
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

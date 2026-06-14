1)
added dependencies : 
shared_preferences: ^2.2.2
  google_fonts: ^6.1.0
  crypto: ^3.0.3
  
2)
Replace void main in widget_test.dart with:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pp/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(isLoggedIn: false, name: '', email: ''),
    );
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

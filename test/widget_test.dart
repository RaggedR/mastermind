import 'package:flutter_test/flutter_test.dart';

import 'package:mastermind/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MastermindApp());

    expect(find.text('MASTERMIND'), findsOneWidget);
    expect(find.text("I'll crack\nthe code"), findsOneWidget);
    expect(find.text('AI cracks\nmy code'), findsOneWidget);
  });
}

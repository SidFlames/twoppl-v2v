// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.
import 'package:flutter_test/flutter_test.dart';

import 'package:lumora/main.dart';

void main() {
  testWidgets('SafeSphere app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SafeSphereApp());

    // Verify that the onboarding screen loads with the expected title.
    expect(find.text('Smart Protection\nWhen You Need It Most'), findsWidgets);

    // Verify the 'Next' button is present on the onboarding screen.
    expect(find.text('Next'), findsOneWidget);
  });
}


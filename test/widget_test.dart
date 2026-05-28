import 'package:flutter_test/flutter_test.dart';

import 'package:interview_flutter_codex/main.dart';

void main() {
  testWidgets('Shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const VanSalesApp());

    expect(find.text('Van Sales App'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}

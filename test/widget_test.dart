import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:interview_flutter/main.dart';
import 'package:interview_flutter/providers/auth_provider.dart';
import 'package:interview_flutter/providers/customer_provider.dart';
import 'package:interview_flutter/providers/product_provider.dart';
import 'package:interview_flutter/providers/invoice_provider.dart';
import 'package:interview_flutter/providers/theme_provider.dart';

void main() {
  testWidgets('App launch and sign-in view smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CustomerProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ],
        child: const KanakApp(),
      ),
    );

    // Verify that our login screen loaded and find the Sign In card title
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('PROCEED TO ACCOUNT'), findsOneWidget);
  });
}

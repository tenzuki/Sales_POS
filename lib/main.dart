import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/product_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
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
}

class KanakApp extends StatelessWidget {
  const KanakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'SalesPOS',
      debugShowCheckedModeBanner: false,
      theme: KanakTheme.lightTheme,
      darkTheme: KanakTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const LoginScreen(),
    );
  }
}

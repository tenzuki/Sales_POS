import 'package:flutter/material.dart';

import 'app/app_session.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/login_screen.dart';

void main() {
  runApp(const VanSalesApp());
}

class VanSalesApp extends StatefulWidget {
  const VanSalesApp({super.key});

  @override
  State<VanSalesApp> createState() => _VanSalesAppState();
}

class _VanSalesAppState extends State<VanSalesApp> {
  final AppSession _session = AppSession();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Van Sales Assignment',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006B5E)),
            scaffoldBackgroundColor: const Color(0xFFF2F6F8),
            appBarTheme: const AppBarTheme(centerTitle: false),
            useMaterial3: true,
          ),
          home: _session.isLoggedIn
              ? DashboardScreen(session: _session)
              : LoginScreen(session: _session),
        );
      },
    );
  }
}

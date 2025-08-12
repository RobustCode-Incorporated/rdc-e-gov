import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/login_view.dart';

void main() {
  runApp(const CitoyenApp());
}

class CitoyenApp extends StatelessWidget {
  const CitoyenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portail Citoyen RDC',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginView(),
    );
  }
}
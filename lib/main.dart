import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  // Firebase now starts inside the splash screen, so the app's first frame
  // (the animated splash) appears straight away instead of waiting on it
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BomaBookApp());
}

class BomaBookApp extends StatelessWidget {
  const BomaBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BomaBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
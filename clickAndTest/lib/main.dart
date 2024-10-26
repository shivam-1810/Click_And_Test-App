import 'package:flutter/material.dart';
import 'package:sasta_app/splash_screen.dart';

void main() {
  runApp(const SastaApp());
}

class SastaApp extends StatelessWidget {
  const SastaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Monitoring App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

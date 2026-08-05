import 'package:flutter/material.dart';
import 'app_root.dart';
import 'theme/colors.dart';

void main() {
  runApp(const SulamaApp());
}

class SulamaApp extends StatelessWidget {
  const SulamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parosis Sulama',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Figtree',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand600,
          primary: AppColors.brand600,
        ),
      ),
      home: const AppRoot(),
    );
  }
}

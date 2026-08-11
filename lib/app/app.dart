import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'app_dependencies.dart';
import 'app_gate.dart';

class SulamaApp extends StatelessWidget {
  const SulamaApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

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
      home: AppGate(dependencies: dependencies),
    );
  }
}

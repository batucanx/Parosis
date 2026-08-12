import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';
import 'firebase_options.dart';

export 'app/app.dart';
export 'app/app_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final dependencies = AppDependencies.mock();
  runApp(SulamaApp(dependencies: dependencies));
}

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';

export 'app/app.dart';
export 'app/app_dependencies.dart';

void main() {
  const dependencies = AppDependencies();
  runApp(const SulamaApp(dependencies: dependencies));
}

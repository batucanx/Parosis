import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';

export 'app/app.dart';
export 'app/app_dependencies.dart';

void main() {
  // AppDependencies.mock() kuruluşu, runApp() çağrılmadan ÖNCE
  // PaymentCardsController üzerinden SharedPreferences'a (platform kanalı)
  // erişiyor; bu kanalın çalışabilmesi için binding'in önceden hazır
  // olması gerekiyor. Aksi halde kart listesi sonsuza dek "yükleniyor"
  // durumunda takılı kalıyordu.
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.mock();
  runApp(SulamaApp(dependencies: dependencies));
}

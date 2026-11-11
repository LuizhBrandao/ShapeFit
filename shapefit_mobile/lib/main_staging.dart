import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/app_config.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(AppConfig.stageConfig());
  await initializeDateFormatting('pt_BR', null);

  runApp(const ShapeFitApp());
}

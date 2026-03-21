import 'package:compass_app/main.dart';
import 'package:compass_app/src/di/dependencies.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

void main() {
  Logger.root.level = Level.ALL;
  runApp(MultiProvider(providers: providersLocal, child: const MainApp()));
}

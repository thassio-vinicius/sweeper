import 'package:flutter/material.dart';
import 'package:sweeper/app.dart';
import 'package:sweeper/core/config/app_env.dart';
import 'package:sweeper/core/di/injection.dart';
import 'package:sweeper/core/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  await FirebaseBootstrap.initialize();
  await configureDependencies();
  await warmUpAuthSession();
  runApp(const SweeperApp());
}

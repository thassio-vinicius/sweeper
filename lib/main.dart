import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sweeper/app.dart';
import 'package:sweeper/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  await configureDependencies();
  runApp(SweeperApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured — auth bonus feature disabled until setup.
  }
}

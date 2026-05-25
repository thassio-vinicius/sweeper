import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sweeper/app.dart';
import 'package:sweeper/core/di/injection.dart';
import 'package:sweeper/features/auth/domain/repositories/auth_repository.dart';
import 'package:sweeper/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  await configureDependencies();
  await _restoreAuthSession();
  runApp(SweeperApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase not configured — auth bonus feature disabled until setup.
  }
}

Future<void> _restoreAuthSession() async {
  final authRepository = getIt<AuthRepository>();
  if (!authRepository.isAvailable) return;
  await authRepository.waitForInitialAuthState();
}

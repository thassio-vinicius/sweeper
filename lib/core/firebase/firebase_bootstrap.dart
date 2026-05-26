import 'package:firebase_core/firebase_core.dart';
import 'package:sweeper/core/config/app_env.dart';

/// Initializes Firebase from [AppEnv] — required on every app launch.
abstract final class FirebaseBootstrap {
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: AppEnv.currentPlatformOptions);
  }
}

import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration loaded from `.env` (gitignored).
abstract final class AppEnv {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get googleServerClientId => _require('GOOGLE_SERVER_CLIENT_ID');

  static FirebaseOptions get currentPlatformOptions {
    if (Platform.isAndroid) {
      return FirebaseOptions(
        apiKey: _require('FIREBASE_ANDROID_API_KEY'),
        appId: _require('FIREBASE_ANDROID_APP_ID'),
        messagingSenderId: _optional('FIREBASE_MESSAGING_SENDER_ID') ?? '',
        projectId: _require('FIREBASE_PROJECT_ID'),
        storageBucket: _optional('FIREBASE_STORAGE_BUCKET'),
      );
    }
    if (Platform.isIOS) {
      return FirebaseOptions(
        apiKey: _require('FIREBASE_IOS_API_KEY'),
        appId: _require('FIREBASE_IOS_APP_ID'),
        messagingSenderId: _optional('FIREBASE_MESSAGING_SENDER_ID') ?? '',
        projectId: _require('FIREBASE_PROJECT_ID'),
        storageBucket: _optional('FIREBASE_STORAGE_BUCKET'),
        iosClientId: _optional('FIREBASE_IOS_CLIENT_ID'),
        iosBundleId: _optional('FIREBASE_IOS_BUNDLE_ID'),
      );
    }
    throw UnsupportedError('Sweeper supports Android and iOS only.');
  }

  static String _require(String key) {
    final value = _optional(key);
    if (value == null) {
      throw StateError('Missing required env var: $key');
    }
    return value;
  }

  static String? _optional(String key) {
    final value = dotenv.maybeGet(key)?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration generated from google-services.json and
/// GoogleService-Info.plist in this project.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvIj0IC51OHe_sWOwoMN5QwC_Z-dSqFNI',
    appId: '1:54918616264:android:8c822e1ff5df60d97e81fd',
    messagingSenderId: '54918616264',
    projectId: 'sweeper-14872',
    storageBucket: 'sweeper-14872.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwU53DgTictyVoL0ft8HCvqweyFTJhIgk',
    appId: '1:54918616264:ios:747ca846b24adf5e7e81fd',
    messagingSenderId: '54918616264',
    projectId: 'sweeper-14872',
    storageBucket: 'sweeper-14872.firebasestorage.app',
    iosClientId:
        '54918616264-iqrgqeqndo9nohh0a0ng3mv6srnkk8km.apps.googleusercontent.com',
    iosBundleId: 'com.example.sweeper',
  );
}

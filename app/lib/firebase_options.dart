import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'This platform is not configured yet. Run flutterfire configure to add native app configs.',
        );
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCWJ9nv7kkmvBqS7JYDDp0VV9D7-7fzjxE',
    appId: '1:1063665719129:web:4f2fa63f391754345f1e48',
    messagingSenderId: '1063665719129',
    projectId: 'sme-ksk-rebels-hackathon',
    authDomain: 'sme-ksk-rebels-hackathon.firebaseapp.com',
    storageBucket: 'sme-ksk-rebels-hackathon.firebasestorage.app',
    measurementId: 'G-V932PVHQMG',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCWJ9nv7kkmvBqS7JYDDp0VV9D7-7fzjxE',
    appId: '1:1063665719129:web:4f2fa63f391754345f1e48',
    messagingSenderId: '1063665719129',
    projectId: 'sme-ksk-rebels-hackathon',
    authDomain: 'sme-ksk-rebels-hackathon.firebaseapp.com',
    storageBucket: 'sme-ksk-rebels-hackathon.firebasestorage.app',
    measurementId: 'G-V932PVHQMG',
  );
}

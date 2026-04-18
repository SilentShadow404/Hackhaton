import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _localHost = 'http://localhost:4000';
  static const String _androidEmulatorHost = 'http://10.0.2.2:4000';

  static String get apiBaseUrl {
    if (kIsWeb) {
      return _localHost;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidEmulatorHost;
      default:
        return _localHost;
    }
  }
}

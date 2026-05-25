import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sweeper/core/config/app_access_config.dart';

AppAccessConfig createAppAccessConfig() {
  final androidGuestModeEnabled = !kIsWeb && Platform.isAndroid;
  return AppAccessConfig(androidGuestModeEnabled: androidGuestModeEnabled);
}

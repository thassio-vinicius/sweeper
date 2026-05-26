import 'dart:io' show Platform;

import 'package:sweeper_auth/config/app_access_config.dart';

AppAccessConfig createAppAccessConfig() {
  return AppAccessConfig(androidGuestModeEnabled: Platform.isAndroid);
}

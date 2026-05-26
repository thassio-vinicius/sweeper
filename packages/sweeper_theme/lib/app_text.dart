/// Contextual text transforms applied at display time (not in translation files).
abstract final class AppText {
  /// HUD / eyebrow labels styled as small caps.
  static String labelCaps(String value) => value.toUpperCase();

  /// High-impact callouts (e.g. magic bomb banner).
  static String calloutCaps(String value) => value.toUpperCase();
}

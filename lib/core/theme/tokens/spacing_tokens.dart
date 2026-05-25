import 'radius_tokens.dart';

/// Spacing scale tokens.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 18.0;
  static const xxl = 24.0;
  static const boardPadding = 13.0;
  static const cellGap = 6.0;

  /// Border radius aliases kept for existing call sites.
  static const cardRadius = AppRadii.md;
  static const cellRadius = AppRadii.sm;
}

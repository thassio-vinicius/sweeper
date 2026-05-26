/// Text glyph tokens for in-app symbols.
abstract final class AppGlyphs {
  static const piece = '◆';
  static const trendUp = '▲';
  static const trendDown = '▼';
  static const unavailable = '--';

  /// Price trend indicator for a signed direction (`-1` down, `0`/`1` up).
  static String trendIndicator(int direction) =>
      direction < 0 ? trendDown : trendUp;
}

/// Platform access rules resolved once at app startup.
class AppAccessConfig {
  const AppAccessConfig({required this.androidGuestModeEnabled});

  /// When true, Android users may enter an in-memory guest session without sign-in.
  final bool androidGuestModeEnabled;
}

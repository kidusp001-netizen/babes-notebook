/// App runtime mode — this is a personal gift app for one person.
class AppConfig {
  AppConfig._();

  /// No login, journal saved on device. Default for the gift build.
  static const personalMode = bool.fromEnvironment(
    'PERSONAL_MODE',
    defaultValue: true,
  );

  /// Dev preview with sample entries (flutter run --dart-define=PREVIEW_MODE=true).
  static const previewMode = bool.fromEnvironment(
    'PREVIEW_MODE',
    defaultValue: false,
  );

  static bool get skipAuth => personalMode || previewMode;

  static bool get useLocalJournal => personalMode || previewMode;

  static bool get useSupabase => !personalMode && !previewMode;
}

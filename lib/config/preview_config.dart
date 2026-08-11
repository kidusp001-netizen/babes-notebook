/// Local preview without Supabase. Run with:
/// `flutter run -d chrome --dart-define=PREVIEW_MODE=true`
class PreviewConfig {
  static const enabled = bool.fromEnvironment(
    'PREVIEW_MODE',
    defaultValue: false,
  );
}

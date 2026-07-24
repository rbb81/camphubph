import '../models/app_settings.dart';

/// The single shared `AppSettings` instance, mutated directly by
/// `SettingsScreen` so toggle state survives navigating away and back
/// within a session. See `AppSettings`'s doc comment for how this shape
/// differs from this app's usual shared-mutable-list convention.
final sampleSettings = AppSettings();

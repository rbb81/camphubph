import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The single piece of global reactive app state in this codebase. Screens
/// read the current value via [ValueListenableBuilder]; [CamperApp] (in
/// main.dart) rebuilds its [MaterialApp] when it changes, live-retheming
/// the whole app. Everything else here is per-screen sample data (see
/// CLAUDE.md) — this exists because a theme choice has to affect the
/// [MaterialApp] root, which no screen can reach via a shared list/object.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

class AppColors {
  AppColors._();

  static const brand = Color(0xFF3557E8);
  static const brandStrong = Color(0xFF1B2A63);
  static const gold = Color(0xFFFFC94D);
  static const danger = Color(0xFFB3261E);

  static const backgroundLight = Color(0xFFF6F7FC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceMutedLight = Color(0xFFEEF1FB);
  static const borderLight = Color(0xFFE2E6F5);
  static const foregroundLight = Color(0xFF12183A);

  static const backgroundDark = Color(0xFF0B1030);
  static const surfaceDark = Color(0xFF141B45);
  static const surfaceMutedDark = Color(0xFF1B2456);
  static const borderDark = Color(0xFF262F66);
  static const foregroundDark = Color(0xFFEDEFFA);
  static const brandDark = Color(0xFF5B7CFF);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    border: AppColors.borderLight,
    foreground: AppColors.foregroundLight,
    accent: AppColors.brand,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    border: AppColors.borderDark,
    foreground: AppColors.foregroundDark,
    accent: AppColors.brandDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color border,
    required Color foreground,
    required Color accent,
  }) {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: foreground,
      displayColor: foreground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        brightness: brightness,
      ).copyWith(primary: accent, secondary: AppColors.gold, error: AppColors.danger),
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : null,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'tokens.dart';

const appFont = 'IBMPlexSansArabic';

/// Builds the light or dark theme from [AppTokens].
ThemeData buildTheme(Brightness brightness) {
  final t = brightness == Brightness.dark ? AppTokens.dark : AppTokens.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.primary,
    onPrimary: t.onPrimary,
    secondary: t.info,
    onSecondary: t.card,
    tertiary: t.accent,
    onTertiary: t.onAccent,
    error: t.problem,
    onError: t.card,
    surface: t.card,
    onSurface: t.text,
    onSurfaceVariant: t.textSecondary,
    outline: t.border,
    outlineVariant: t.divider,
    surfaceContainerHighest: t.tonalBg,
  );
  final radius = BorderRadius.circular(Gap.radius);
  final base = ThemeData(useMaterial3: true, brightness: brightness, colorScheme: scheme, fontFamily: appFont);
  return base.copyWith(
    extensions: [t],
    scaffoldBackgroundColor: t.bg,
    textTheme: base.textTheme.apply(bodyColor: t.text, displayColor: t.text),
    appBarTheme: AppBarTheme(
      backgroundColor: t.bg,
      foregroundColor: t.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: appFont, fontSize: 17, fontWeight: FontWeight.w700, color: t.text),
    ),
    cardTheme: CardThemeData(
      color: t.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: radius),
    ),
    dividerTheme: DividerThemeData(color: t.divider, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.card,
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: t.textSecondary, fontSize: 16),
      border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: t.border)),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: t.border)),
      focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: t.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: t.problem)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.primary,
        foregroundColor: t.onPrimary,
        minimumSize: const Size(Gap.touch, Gap.touch),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontFamily: appFont, fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.primary,
        minimumSize: const Size(Gap.touch, Gap.touch),
        textStyle: const TextStyle(fontFamily: appFont, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Gap.radiusSmall)),
    ),
  );
}

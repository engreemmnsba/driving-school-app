import 'package:flutter/material.dart';

/// Colour tokens from the design canvas (Tokens screen). Each colour has ONE meaning on every screen.
/// Money: in/paid = [money], debt = [debt], discount/info = [info], problems only = [problem].
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.bg,
    required this.card,
    required this.border,
    required this.divider,
    required this.text,
    required this.textSecondary,
    required this.money,
    required this.moneyBg,
    required this.debt,
    required this.info,
    required this.tonalBg,
    required this.problem,
    required this.warning,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.muted,
  });

  final Color bg;
  final Color card;
  final Color border;
  final Color divider;

  /// Titles, amounts going out / charges.
  final Color text;

  /// Details, times.
  final Color textSecondary;

  /// Money in / paid (green).
  final Color money;
  final Color moneyBg;

  /// Still owed (amber).
  final Color debt;

  /// Discount / credit / financial information (teal).
  final Color info;
  final Color tonalBg;

  /// Problems only: difference, negative, failure (red).
  final Color problem;

  /// Late / needs you (orange).
  final Color warning;

  /// Links, selected state, main buttons.
  final Color primary;
  final Color onPrimary;

  /// The single yellow "new student" action.
  final Color accent;
  final Color onAccent;

  /// Idle dots, disabled.
  final Color muted;

  static const light = AppTokens(
    bg: Color(0xFFF3F5F4),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFDDE3E1),
    divider: Color(0xFFEEF1F0),
    text: Color(0xFF14211F),
    textSecondary: Color(0xFF55625F),
    money: Color(0xFF1E6B3E),
    moneyBg: Color(0xFFE3F1E8),
    debt: Color(0xFFB54708),
    info: Color(0xFF0A4246),
    tonalBg: Color(0xFFE1EEED),
    problem: Color(0xFFB3261E),
    warning: Color(0xFFC2410C),
    primary: Color(0xFF0E5A5F),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFF2B705),
    onAccent: Color(0xFF14211F),
    muted: Color(0xFFB5BFBC),
  );

  static const dark = AppTokens(
    bg: Color(0xFF0F1615),
    card: Color(0xFF18211F),
    border: Color(0xFF2E3B38),
    divider: Color(0xFF253230),
    text: Color(0xFFE8EEEC),
    textSecondary: Color(0xFFA9B5B2),
    money: Color(0xFF5BC98A),
    moneyBg: Color(0xFF17301F),
    debt: Color(0xFFF0A04B),
    info: Color(0xFF7FD3CF),
    tonalBg: Color(0xFF1D3634),
    problem: Color(0xFFFF8A80),
    warning: Color(0xFFF59A5B),
    primary: Color(0xFF5CC2BE),
    onPrimary: Color(0xFF0F1615),
    accent: Color(0xFFF2B705),
    onAccent: Color(0xFF14211F),
    muted: Color(0xFF5E6B68),
  );

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(AppTokens? other, double t) => t < 0.5 || other == null ? this : other;
}

extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>() ?? AppTokens.light;
}

/// Spacing and radii used across screens.
abstract final class Gap {
  static const page = 16.0;
  static const section = 14.0;
  static const radius = 14.0;
  static const radiusSmall = 10.0;
  static const touch = 44.0;
}

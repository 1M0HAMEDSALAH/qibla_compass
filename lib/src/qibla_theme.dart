import 'package:flutter/material.dart';

/// Design tokens for the Qibla compass package.
///
/// Override these to customise the look of [QiblaScreen] and
/// [QiblaCompassWidget].
class QiblaTheme {
  const QiblaTheme({
    this.backgroundDark = const Color(0xFF0A2E24),
    this.backgroundMid = const Color(0xFF0F3E33),
    this.gold = const Color(0xFFCDA047),
    this.goldLight = const Color(0xFFE8BF6A),
    this.compassFaceStart = const Color(0xFF1A5C4A),
    this.compassFaceEnd = const Color(0xFF0A2E24),
    this.northIndicator = const Color(0xFFFF4757),
    this.textPrimary = Colors.white,
    this.textSecondary = Colors.white70,
    this.accentCyan = const Color(0xFF00D9FF),
    this.cardBackground = const Color(0x1AFFFFFF),
    this.cardBorder = const Color(0x33FFFFFF),
  });

  /// Default green-tinted dark theme.
  static const QiblaTheme defaultTheme = QiblaTheme();

  /// Midnight blue alternative theme.
  static const QiblaTheme midnightTheme = QiblaTheme(
    backgroundDark: Color(0xFF0A0F2E),
    backgroundMid: Color(0xFF0F1A3E),
    compassFaceStart: Color(0xFF1A2A6C),
    compassFaceEnd: Color(0xFF0A0F2E),
    accentCyan: Color(0xFF4FC3F7),
  );

  final Color backgroundDark;
  final Color backgroundMid;
  final Color gold;
  final Color goldLight;
  final Color compassFaceStart;
  final Color compassFaceEnd;
  final Color northIndicator;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentCyan;
  final Color cardBackground;
  final Color cardBorder;
}

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Neon Dark (default) ────────────────────────────────────────────────────
  static const Color backgroundDeep     = Color(0xFF0D1117);
  static const Color backgroundBase     = Color(0xFF161B22);
  static const Color backgroundCard     = Color(0xFF1C2333);
  static const Color backgroundElevated = Color(0xFF21262D);

  static const Color neonGreen      = Color(0xFF00FF88);
  static const Color neonGreenDim   = Color(0xFF00CC6A);
  static const Color neonGreenFaint = Color(0x2600FF88);

  static const Color alertFire         = Color(0xFFFF3B30);
  static const Color alertFireFaint    = Color(0x26FF3B30);
  static const Color alertDisease      = Color(0xFFFF9500);
  static const Color alertDiseaseFaint = Color(0x26FF9500);

  static const Color textPrimary   = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF7D8590);
  static const Color textMuted     = Color(0xFF484F58);
  static const Color textInverse   = Color(0xFF0D1117);

  static const Color statusOnline  = Color(0xFF00FF88);
  static const Color statusWarning = Color(0xFFFF9500);
  static const Color statusOffline = Color(0xFFFF3B30);
  static const Color statusIdle    = Color(0xFF7D8590);

  static const Color borderDim  = Color(0xFF21262D);
  static const Color borderGlow = Color(0xFF00FF88);

  static const LinearGradient neonGreenGradient = LinearGradient(
    colors: [neonGreen, neonGreenDim],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [backgroundCard, backgroundElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── Per-theme palette — used by ThemePicker & AppTheme ──────────────────────

class AppThemePalette {
  final String id;
  final String label;
  final String emoji;
  final Color scaffold;
  final Color card;
  final Color primary;
  final Color secondary;
  final Color text;
  final Color textSub;
  final Brightness brightness;
  final List<Color> gradientColors;

  const AppThemePalette({
    required this.id,
    required this.label,
    required this.emoji,
    required this.scaffold,
    required this.card,
    required this.primary,
    required this.secondary,
    required this.text,
    required this.textSub,
    required this.brightness,
    required this.gradientColors,
  });

  static const neonDark = AppThemePalette(
    id: 'neonDark',
    label: 'Neon Dark',
    emoji: '',
    scaffold: Color(0xFF0D1117),
    card: Color(0xFF1C2333),
    primary: Color(0xFF00FF88),
    secondary: Color(0xFF00CC6A),
    text: Color(0xFFE6EDF3),
    textSub: Color(0xFF7D8590),
    brightness: Brightness.dark,
    gradientColors: [Color(0xFF00FF88), Color(0xFF00CC6A)],
  );

  static const oceanBlue = AppThemePalette(
    id: 'oceanBlue',
    label: 'Ocean Blue',
    emoji: '',
    scaffold: Color(0xFF060E1F),
    card: Color(0xFF0D1E3C),
    primary: Color(0xFF00D4FF),
    secondary: Color(0xFF0099CC),
    text: Color(0xFFD6EAF8),
    textSub: Color(0xFF5D8AA8),
    brightness: Brightness.dark,
    gradientColors: [Color(0xFF00D4FF), Color(0xFF0066AA)],
  );

  static const sunsetEmber = AppThemePalette(
    id: 'sunsetEmber',
    label: 'Sunset Ember',
    emoji: '',
    scaffold: Color(0xFF1A0D0A),
    card: Color(0xFF2D1410),
    primary: Color(0xFFFF6B35),
    secondary: Color(0xFFE84A1A),
    text: Color(0xFFFDF0EC),
    textSub: Color(0xFF9D6B5E),
    brightness: Brightness.dark,
    gradientColors: [Color(0xFFFF6B35), Color(0xFFFF3B30)],
  );

  static const forestLight = AppThemePalette(
    id: 'forestLight',
    label: 'Forest Light',
    emoji: '',
    scaffold: Color(0xFFF0F7F4),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF2D6A4F),
    secondary: Color(0xFF52B788),
    text: Color(0xFF1B3A2D),
    textSub: Color(0xFF5A8A70),
    brightness: Brightness.light,
    gradientColors: [Color(0xFF52B788), Color(0xFF2D6A4F)],
  );

  static const galaxyPurple = AppThemePalette(
    id: 'galaxyPurple',
    label: 'Galaxy Purple',
    emoji: '',
    scaffold: Color(0xFF0A0614),
    card: Color(0xFF150D2A),
    primary: Color(0xFFA855F7),
    secondary: Color(0xFF7C3AED),
    text: Color(0xFFEDE9FE),
    textSub: Color(0xFF7C6FA0),
    brightness: Brightness.dark,
    gradientColors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
  );

  static const List<AppThemePalette> all = [
    neonDark,
    oceanBlue,
    sunsetEmber,
    forestLight,
    galaxyPurple,
  ];

  static AppThemePalette byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => neonDark);
}

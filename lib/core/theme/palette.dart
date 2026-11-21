import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// angoothaPe brand tokens from the V2 prototype.
class ApPalette extends ThemeExtension<ApPalette> {
  const ApPalette({
    required this.canvas,
    required this.card,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.accent,
    required this.accentText,
    required this.accentSoft,
    required this.success,
    required this.successBg,
    required this.error,
    required this.errorBg,
    required this.warning,
    required this.warningBg,
    required this.info,
    required this.infoBg,
    required this.nav,
    required this.hero,
    required this.onHero,
    required this.heroMuted,
    required this.surface2,
    required this.lineStrong,
    required this.inkDis,
  });

  final Color canvas;
  final Color card;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color line;
  final Color primary;
  final Color onPrimary;
  final Color primarySoft;
  final Color accent;
  final Color accentText;
  final Color accentSoft;
  final Color success;
  final Color successBg;
  final Color error;
  final Color errorBg;
  final Color warning;
  final Color warningBg;
  final Color info;
  final Color infoBg;
  final Color nav;
  final Color hero;
  final Color onHero;
  final Color heroMuted;
  final Color surface2;
  final Color lineStrong;
  final Color inkDis;

  static const light = ApPalette(
    canvas: Color(0xFFF2F1F8),
    card: Colors.white,
    ink: Color(0xFF1B1A2E),
    ink2: Color(0xFF56546B),
    ink3: Color(0xFF737189),
    line: Color(0xFFDEDDE9),
    primary: Color(0xFF302D70),
    onPrimary: Colors.white,
    primarySoft: Color(0xFFF1F0FA),
    accent: Color(0xFFF2662F),
    accentText: Color(0xFFB8441A),
    accentSoft: Color(0xFFFFF3ED),
    success: Color(0xFF2B7C4C),
    successBg: Color(0xFFEEF8F2),
    error: Color(0xFFC62F35),
    errorBg: Color(0xFFFDEDEE),
    warning: Color(0xFF9A5200),
    warningBg: Color(0xFFFFF6E5),
    info: Color(0xFF2563EB),
    infoBg: Color(0xFFEAF1FE),
    nav: Color(0xFF1B1944),
    hero: Color(0xFF1B1944),
    onHero: Colors.white,
    heroMuted: Color(0xFFC6C4EC),
    surface2: Color(0xFFEEEEF5),
    lineStrong: Color(0xFFC4C3D4),
    inkDis: Color(0xFF9A98B0),
  );

  static const dark = ApPalette(
    canvas: Color(0xFF0B0A24),
    card: Color(0xFF1C1A40),
    ink: Color(0xFFF4F3FB),
    ink2: Color(0xFFB4B2CC),
    ink3: Color(0xFF9896B8),
    line: Color(0xFF363364),
    primary: Color(0xFFA5A1F0),
    onPrimary: Color(0xFF12102E),
    primarySoft: Color(0xFF25225A),
    accent: Color(0xFFF2662F),
    accentText: Color(0xFFFBA078),
    accentSoft: Color(0xFF3A2230),
    success: Color(0xFF62BF87),
    successBg: Color(0xFF173326),
    error: Color(0xFFF2777C),
    errorBg: Color(0xFF3B1B22),
    warning: Color(0xFFF5B54A),
    warningBg: Color(0xFF3A2A10),
    info: Color(0xFF7AA7F7),
    infoBg: Color(0xFF18264A),
    nav: Color(0xFF26234F),
    hero: Color(0xFF1B1944),
    onHero: Colors.white,
    heroMuted: Color(0xFFC6C4EC),
    surface2: Color(0xFF26234F),
    lineStrong: Color(0xFF4A4780),
    inkDis: Color(0xFF6F6D8E),
  );

  static const indigo900 = Color(0xFF1B1944);
  static const orange600 = Color(0xFFDD5520);
  static const orange700 = Color(0xFFB8441A);
  static const greenDot = Color(0xFF4FB477);
  static const indigo = Color(0xFF302D70);

  @override
  ApPalette copyWith() => this;

  @override
  ApPalette lerp(ThemeExtension<ApPalette>? other, double t) => this;
}

ApPalette ap(BuildContext context) =>
    Theme.of(context).extension<ApPalette>() ?? ApPalette.light;

TextStyle display(
  double size, {
  FontWeight weight = FontWeight.w600,
  Color? color,
  double? letterSpacing,
}) => GoogleFonts.poppins(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: letterSpacing ?? -0.3,
  height: 1.15,
);

TextStyle body(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
}) => GoogleFonts.inter(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height ?? 1.35,
);

ThemeData apTheme(ApPalette p, Brightness brightness) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.canvas,
    splashFactory: InkSparkle.splashFactory,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.accent,
      onSecondary: Colors.white,
      error: p.error,
      onError: Colors.white,
      surface: p.card,
      onSurface: p.ink,
    ),
  );
  return base.copyWith(
    extensions: [p],
    textTheme: GoogleFonts.interTextTheme(base.textTheme)
        .apply(bodyColor: p.ink, displayColor: p.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: p.ink,
      titleTextStyle: display(18, color: p.ink),
    ),
    dividerColor: p.line,
  );
}

List<BoxShadow> cardShadow() => const [
  BoxShadow(color: Color(0x0A12102E), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(
    color: Color(0x2912102E),
    blurRadius: 34,
    offset: Offset(0, 14),
    spreadRadius: -14,
  ),
];

BoxDecoration cardBox(ApPalette p, {double radius = 28}) => BoxDecoration(
  color: p.card,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: cardShadow(),
);

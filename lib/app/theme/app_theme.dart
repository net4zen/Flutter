import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Central theme configuration for Weatherly.
/// All colors, typography, and component themes are defined here.
/// Widgets should reference theme tokens — never hardcode colors or spacings.
class AppTheme {
  AppTheme._();

  // ─── Brand palette ──────────────────────────────────────────────────────────
  static const Color _primaryLight = Color(0xFF1B6CA8);
  static const Color _primaryDark = Color(0xFF4FC3F7);
  static const Color _secondaryLight = Color(0xFF0288D1);
  static const Color _secondaryDark = Color(0xFF81D4FA);

  static const Color _backgroundLight = Color(0xFFF0F4F8);
  static const Color _backgroundDark = Color(0xFF0D1B2A);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1A2E3B);
  static const Color _cardDark = Color(0xFF1F3547);

  static const Color _onSurfaceLight = Color(0xFF1A2E3B);
  static const Color _onSurfaceDark = Color(0xFFE8F4FD);
  static const Color _subtleLight = Color(0xFF607D8B);
  static const Color _subtleDark = Color(0xFF90A4AE);

  static const Color _errorColor = Color(0xFFD32F2F);

  // ─── Text styles ─────────────────────────────────────────────────────────────
  static const String _fontFamily = 'Roboto';

  static TextTheme _buildTextTheme(Color onSurface, Color subtle) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 72,
        fontWeight: FontWeight.w300,
        color: onSurface,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 56,
        fontWeight: FontWeight.w300,
        color: onSurface,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurface,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurface,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: subtle,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
        letterSpacing: 1.25,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: subtle,
        letterSpacing: 1.0,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: subtle,
        letterSpacing: 1.5,
      ),
    );
  }

  // ─── Light theme ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: _primaryLight,
      secondary: _secondaryLight,
      surface: _surfaceLight,
      error: _errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _onSurfaceLight,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundLight,
      fontFamily: _fontFamily,
      textTheme: _buildTextTheme(_onSurfaceLight, _subtleLight),
      appBarTheme: AppBarTheme(
        backgroundColor: _backgroundLight,
        foregroundColor: _onSurfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _onSurfaceLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _subtleLight.withAlpha(50)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _subtleLight.withAlpha(50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: _onSurfaceLight),
      ),
      dividerTheme: DividerThemeData(
        color: _subtleLight.withAlpha(30),
        thickness: 1,
        space: 1,
      ),
      extensions: const [AppColors.light],
    );
  }

  // ─── Dark theme ──────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: _primaryDark,
      secondary: _secondaryDark,
      surface: _surfaceDark,
      error: const Color(0xFFEF5350),
      onPrimary: _backgroundDark,
      onSecondary: _backgroundDark,
      onSurface: _onSurfaceDark,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundDark,
      fontFamily: _fontFamily,
      textTheme: _buildTextTheme(_onSurfaceDark, _subtleDark),
      appBarTheme: AppBarTheme(
        backgroundColor: _backgroundDark,
        foregroundColor: _onSurfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _onSurfaceDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: _cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _subtleDark.withAlpha(40)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _subtleDark.withAlpha(40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryDark, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: _backgroundDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: _onSurfaceDark),
      ),
      dividerTheme: DividerThemeData(
        color: _subtleDark.withAlpha(30),
        thickness: 1,
        space: 1,
      ),
      extensions: const [AppColors.dark],
    );
  }
}

/// Custom theme extension for semantic color tokens not in Material ColorScheme.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color cardBackground;
  final Color subtleText;
  final Color backgroundPage;
  final Color warning;
  final Color success;
  final Color cachedBanner;
  final Color refreshingIndicator;

  const AppColors({
    required this.cardBackground,
    required this.subtleText,
    required this.backgroundPage,
    required this.warning,
    required this.success,
    required this.cachedBanner,
    required this.refreshingIndicator,
  });

  static const light = AppColors(
    cardBackground: Color(0xFFFFFFFF),
    subtleText: Color(0xFF607D8B),
    backgroundPage: Color(0xFFF0F4F8),
    warning: Color(0xFFF57C00),
    success: Color(0xFF388E3C),
    cachedBanner: Color(0xFFFFF3E0),
    refreshingIndicator: Color(0xFF1B6CA8),
  );

  static const dark = AppColors(
    cardBackground: Color(0xFF1F3547),
    subtleText: Color(0xFF90A4AE),
    backgroundPage: Color(0xFF0D1B2A),
    warning: Color(0xFFFFA726),
    success: Color(0xFF66BB6A),
    cachedBanner: Color(0xFF2D2000),
    refreshingIndicator: Color(0xFF4FC3F7),
  );

  @override
  AppColors copyWith({
    Color? cardBackground,
    Color? subtleText,
    Color? backgroundPage,
    Color? warning,
    Color? success,
    Color? cachedBanner,
    Color? refreshingIndicator,
  }) {
    return AppColors(
      cardBackground: cardBackground ?? this.cardBackground,
      subtleText: subtleText ?? this.subtleText,
      backgroundPage: backgroundPage ?? this.backgroundPage,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      cachedBanner: cachedBanner ?? this.cachedBanner,
      refreshingIndicator: refreshingIndicator ?? this.refreshingIndicator,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      backgroundPage: Color.lerp(backgroundPage, other.backgroundPage, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      cachedBanner: Color.lerp(cachedBanner, other.cachedBanner, t)!,
      refreshingIndicator: Color.lerp(
        refreshingIndicator,
        other.refreshingIndicator,
        t,
      )!,
    );
  }
}

/// Convenience extension to access [AppColors] from [BuildContext].
extension AppColorsX on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}

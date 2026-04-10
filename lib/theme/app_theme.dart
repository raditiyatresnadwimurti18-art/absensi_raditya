import 'package:flutter/material.dart';

class AppColors {
  // Brand colors (tetap sama di semua tema)
  static const Color primaryBlue = Color(0xFF0074B7);
  static const Color primaryYellow = Color(0xFFFFD700);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Colors.white;
  static const Color lightText = Colors.black87;
  static const Color lightSubText = Colors.black45;

  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkSubText = Color(0xFF9E9E9E);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightText),
    ),
    extensions: const [AppColorExtension.light],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
    ),
    extensions: const [AppColorExtension.dark],
  );
}

/// Extension untuk mengakses warna custom via Theme.of(context)
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  final Color background;
  final Color card;
  final Color text;
  final Color subText;

  const AppColorExtension({
    required this.background,
    required this.card,
    required this.text,
    required this.subText,
  });

  static const light = AppColorExtension(
    background: AppColors.lightBackground,
    card: AppColors.lightCard,
    text: AppColors.lightText,
    subText: AppColors.lightSubText,
  );

  static const dark = AppColorExtension(
    background: AppColors.darkBackground,
    card: AppColors.darkCard,
    text: AppColors.darkText,
    subText: AppColors.darkSubText,
  );

  @override
  AppColorExtension copyWith({
    Color? background,
    Color? card,
    Color? text,
    Color? subText,
  }) {
    return AppColorExtension(
      background: background ?? this.background,
      card: card ?? this.card,
      text: text ?? this.text,
      subText: subText ?? this.subText,
    );
  }

  @override
  AppColorExtension lerp(AppColorExtension? other, double t) {
    if (other is! AppColorExtension) return this;
    return AppColorExtension(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      text: Color.lerp(text, other.text, t)!,
      subText: Color.lerp(subText, other.subText, t)!,
    );
  }
}

/// Helper extension agar lebih mudah dipanggil
extension ThemeContextExtension on BuildContext {
  AppColorExtension get appColors =>
      Theme.of(this).extension<AppColorExtension>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

import 'package:flutter/material.dart';

class ThemeColors {
  final Color divider;

  final Color secondaryText;

  final Color primaryText;

  final Color accent;

  final Color textIcons;

  final Color primary;

  final Color lightPrimary;

  final Color darkPrimary;

  const ThemeColors({
    required this.divider,

    required this.secondaryText,

    required this.primaryText,

    required this.accent,

    required this.textIcons,

    required this.primary,

    required this.lightPrimary,

    required this.darkPrimary,
  });
}

ThemeData themeDataFromColors(ThemeColors colors) {
  return ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.textIcons,
      ),
    ),
    useMaterial3: true,

    primaryColor: colors.primary,

    primaryColorLight: colors.lightPrimary,

    primaryColorDark: colors.darkPrimary,

    dividerColor: colors.divider,

    hintColor: colors.accent,

    scaffoldBackgroundColor: Colors.white,

    textTheme: TextTheme(
      // Old bodyText1 â†’ primary text
      bodyLarge: TextStyle(color: colors.primaryText),

      bodyMedium: TextStyle(color: colors.primaryText),

      // Old bodyText2 â†’ secondary text
      bodySmall: TextStyle(color: colors.secondaryText),

      // Titles / headlines â†’ primary text
      titleLarge: TextStyle(color: colors.primaryText),

      titleMedium: TextStyle(color: colors.primaryText),

      titleSmall: TextStyle(color: colors.secondaryText),

      headlineLarge: TextStyle(color: colors.primaryText),

      headlineMedium: TextStyle(color: colors.primaryText),

      headlineSmall: TextStyle(color: colors.primaryText),

      // Labels (buttons, inputs, captions)
      labelLarge: TextStyle(color: colors.textIcons),

      labelMedium: TextStyle(color: colors.secondaryText),

      labelSmall: TextStyle(color: colors.secondaryText),

      // Optional display styles
      displayLarge: TextStyle(color: colors.primaryText),

      displayMedium: TextStyle(color: colors.primaryText),

      displaySmall: TextStyle(color: colors.primaryText),
    ),

    iconTheme: IconThemeData(color: colors.textIcons),
  );
}

// Orange - BlueGray theme

const amberRedTheme = ThemeColors(
  divider: Color(0xFFBDBDBD),

  secondaryText: Color(0xFF757575),

  primaryText: Color(0xFF212121),

  accent: Color(0xFF607D8B),

  textIcons: Color(0xFFFFFFFF),

  primary: Color(0xFFFF5722),

  lightPrimary: Color(0xFFFFCCBC),

  darkPrimary: Color.fromARGB(255, 130, 30, 0),
);


// Teal - Blue theme

const tealBlueTheme = ThemeColors(
  divider: Color(0xFFBDBDBD),

  secondaryText: Color(0xFF757575),

  primaryText: Color(0xFF212121),

  accent: Color(0xFF448AFF),

  textIcons: Color(0xFFFFFFFF),

  primary: Color(0xFF009688),

  lightPrimary: Color(0xFFB2DFDB),

  darkPrimary: Color(0xFF00796B),
);

// Amber - Red theme

const orangeBlueGrayTheme = ThemeColors(
  divider: Color(0xFFBDBDBD),

  secondaryText: Color(0xFF757575),

  primaryText: Color(0xFF212121),

  accent: Color(0xFFFF5252),

  textIcons: Color(0xFF212121),

  primary: Color(0xFFFFC107),

  lightPrimary: Color(0xFFFFECB3),

  darkPrimary: Color(0xFFFFA000),
);




const amberRedDarkTheme = ThemeColors(
  divider: Color(0xFF424242),

  secondaryText: Color(0xFFB0B0B0),

  primaryText: Color(0xFFF5F5F5),

  accent: Color(0xFF90CAF9),

  textIcons: Color(0xFFFFFFFF),

  primary: Color(0xFFFF5722),

  lightPrimary: Color.fromARGB(255, 157, 0, 0),

  darkPrimary: Color.fromARGB(255, 252, 161, 133),
);

const tealBlueDarkTheme = ThemeColors(
  divider: Color(0xFF424242),

  secondaryText: Color(0xFFB0B0B0),

  primaryText: Color(0xFFF5F5F5),

  accent: Color(0xFF82B1FF),

  textIcons: Color(0xFFFFFFFF),

  primary: Color(0xFF26A69A),

  lightPrimary: Color(0xFF00695C),

  darkPrimary: Color(0xFF4DB6AC),
);

const orangeBlueGrayDarkTheme = ThemeColors(
  divider: Color(0xFF424242),

  secondaryText: Color(0xFFB0B0B0),

  primaryText: Color(0xFFF5F5F5),

  accent: Color(0xFFFF8A80),

  textIcons: Color(0xFFFFFFFF),

  primary: Color(0xFFFFCA28),

  lightPrimary: Color(0xFFFF8F00),

  darkPrimary:  Color(0xFFFFD54F),
);
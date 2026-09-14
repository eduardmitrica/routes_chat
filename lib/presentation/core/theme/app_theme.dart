import 'package:flutter/material.dart';
import 'package:routes_chat/application/settings/appearance/appearance_bloc.dart';

import 'app_colors.dart';

/// The app's look, light and dark, built from one brand color.
///
/// Screens take colors and text styles from the theme rather than naming
/// them, so both themes stay complete. Buttons follow one hierarchy:
/// a [FilledButton] for the main action on a screen, an [OutlinedButton] for
/// an alternative to it, and a [TextButton] for a way around or out.
abstract final class AppTheme {
  /// The purple the app has always used.
  static const brand = Color(0xFF7C4DFF);

  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  /// For the main action when it destroys something for good.
  static ButtonStyle destructiveButton(ColorScheme scheme) =>
      FilledButton.styleFrom(
        backgroundColor: scheme.error,
        foregroundColor: scheme.onError,
      );

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: brightness,
      // Keeps the primary close to the brand purple.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    const rounded = BorderRadius.all(Radius.circular(14));
    const buttonShape = RoundedRectangleBorder(borderRadius: rounded);
    const buttonSize = Size(64, 48);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 24);
    // From the type scale itself: the theme's own text styles get their sizes
    // only once the theme is in use, and a button style replaces the default
    // text style rather than adding to it.
    final buttonText = Typography.material2021().englishLike.labelLarge!
        .copyWith(fontWeight: FontWeight.w600);
    OutlineInputBorder fieldBorder(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: rounded,
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        scrolledUnderElevation: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonText,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        border: fieldBorder(scheme.outline),
        enabledBorder: fieldBorder(scheme.outlineVariant),
        focusedBorder: fieldBorder(scheme.primary, width: 2),
        errorBorder: fieldBorder(scheme.error),
        focusedErrorBorder: fieldBorder(scheme.error, width: 2),
        disabledBorder: fieldBorder(scheme.onSurface.withValues(alpha: 0.12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: rounded),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      listTileTheme: ListTileThemeData(iconColor: scheme.onSurfaceVariant),
      extensions: [AppColors.fromScheme(scheme)],
    );
  }
}

extension AppearanceThemeMode on Appearance {
  ThemeMode get themeMode => switch (this) {
    Appearance.system => ThemeMode.system,
    Appearance.light => ThemeMode.light,
    Appearance.dark => ThemeMode.dark,
  };
}

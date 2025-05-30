import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Paleta de colores para el modo claro
  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Colors.pink,
    onPrimary: Colors.white,
    primaryContainer: Colors.pink[100]!,
    onPrimaryContainer: Colors.pink[800]!,
    secondary: Colors.purple[300]!,
    onSecondary: Colors.white,
    secondaryContainer: Colors.purple[100]!,
    onSecondaryContainer: Colors.purple[800]!,
    tertiary: Colors.amber[400]!,
    onTertiary: Colors.black,
    tertiaryContainer: Colors.amber[100]!,
    onTertiaryContainer: Colors.amber[900]!,
    error: Colors.red,
    onError: Colors.white,
    errorContainer: Colors.red[100]!,
    onErrorContainer: Colors.red[900]!,
    surface: Color.fromRGBO(242, 217, 208, 1),
    onSurface: Colors.black,
    surfaceContainerHighest: Colors.grey[200]!,
    onSurfaceVariant: Colors.grey[700]!,
    outline: Colors.grey[400]!,
    shadow: Colors.black.withOpacity(0.1),
    inverseSurface: Colors.grey[900]!,
    onInverseSurface: Colors.white,
    inversePrimary: Colors.pink[200]!,
  );

  // Paleta de colores para el modo oscuro
  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.pink[300]!,
    onPrimary: Colors.black,
    primaryContainer: Colors.pink[800]!,
    onPrimaryContainer: Colors.pink[100]!,
    secondary: Colors.purple[200]!,
    onSecondary: Colors.black,
    secondaryContainer: Colors.purple[700]!,
    onSecondaryContainer: Colors.purple[100]!,
    tertiary: Colors.amber[300]!,
    onTertiary: Colors.black,
    tertiaryContainer: Colors.amber[800]!,
    onTertiaryContainer: Colors.amber[100]!,
    error: Colors.red[300]!,
    onError: Colors.black,
    errorContainer: Colors.red[900]!,
    onErrorContainer: Colors.red[100]!,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    surfaceContainerHighest: Color(0xFF2C2C2C),
    onSurfaceVariant: Colors.grey[300]!,
    outline: Colors.grey[600]!,
    shadow: Colors.black.withOpacity(0.3),
    inverseSurface: Colors.grey[100]!,
    onInverseSurface: Colors.black,
    inversePrimary: Colors.pink[700]!,
  );

  // Temas completos para claro y oscuro
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: _lightColorScheme.surface,
    cardColor: Colors.white,
    dividerColor: Colors.grey[300],
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightColorScheme.surface,
      selectedItemColor: _lightColorScheme.primary,
      unselectedItemColor: _lightColorScheme.onSurfaceVariant,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightColorScheme.primary,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _lightColorScheme.surfaceContainerHighest,
      selectedColor: _lightColorScheme.primary,
      labelStyle: TextStyle(color: _lightColorScheme.onSurfaceVariant),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return _lightColorScheme.primary;
        }
        return _lightColorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return _lightColorScheme.primary.withOpacity(0.5);
        }
        return _lightColorScheme.surfaceContainerHighest;
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: _lightColorScheme.primary,
      inactiveTrackColor: _lightColorScheme.primary.withOpacity(0.2),
      thumbColor: _lightColorScheme.primary,
      overlayColor: _lightColorScheme.primary.withOpacity(0.12),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: _darkColorScheme.surface,
    cardColor: _darkColorScheme.surface,
    dividerColor: _darkColorScheme.outline,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkColorScheme.surface,
      selectedItemColor: _darkColorScheme.primary,
      unselectedItemColor: _darkColorScheme.onSurfaceVariant,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkColorScheme.primary,
        foregroundColor: _darkColorScheme.onPrimary,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkColorScheme.primary,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkColorScheme.surfaceContainerHighest,
      selectedColor: _darkColorScheme.primary,
      labelStyle: TextStyle(color: _darkColorScheme.onSurfaceVariant),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkColorScheme.primary;
        }
        return _darkColorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkColorScheme.primary.withOpacity(0.5);
        }
        return _darkColorScheme.surfaceContainerHighest;
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: _darkColorScheme.primary,
      inactiveTrackColor: _darkColorScheme.primary.withOpacity(0.2),
      thumbColor: _darkColorScheme.primary,
      overlayColor: _darkColorScheme.primary.withOpacity(0.12),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _darkColorScheme.surface,
      surfaceTintColor: _darkColorScheme.surfaceContainerHighest,
    ),
  );

  ThemeProvider() {
    _loadThemePreference();
  }

  // Carga la preferencia del tema desde storage
  _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Cambia entre tema claro y oscuro
  toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
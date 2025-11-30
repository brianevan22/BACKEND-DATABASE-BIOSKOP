import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // biru lebih cerah untuk kesan fresh
  static const _seed = Color(0xFF0D47A1);
  static const _primary = Color(0xFF1565C0); // biru utama
  static const _secondary = Color(0xFFFF5E8A); // aksen
  static const _darkButton = Color(0xFF0D47A1);
  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: _primary,
    brightness: Brightness.dark,
  ).copyWith(
    background: const Color(0xFF0B121D),
    surface: const Color(0xFF13202D),
    secondary: _secondary,
    onPrimary: Colors.white,
  );

  // Light theme removed. Only dark theme is used.

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: _darkScheme,
    scaffoldBackgroundColor: _darkScheme.background,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
        .apply(bodyColor: _darkScheme.onBackground),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: _darkScheme.surface,
      foregroundColor: _darkScheme.onSurface,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: _darkScheme.surface,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    iconTheme: IconThemeData(color: _darkScheme.primary),
    cardTheme: ThemeData.dark().cardTheme.copyWith(
          elevation: 4,
          color: const Color(0xFF1C2838),
          shadowColor: Colors.black54,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkScheme.surface.withOpacity(.85),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _darkButton,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkButton,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkButton,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkButton,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkScheme.surfaceVariant,
      contentTextStyle: TextStyle(color: _darkScheme.onSurface),
      behavior: SnackBarBehavior.floating,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    splashColor: _darkScheme.primary.withOpacity(.12),
  );

  static AppBar buildGradientAppBar(
    BuildContext context,
    String title, {
    List<Widget>? actions,
    Widget? leading,
    PreferredSizeWidget? bottom,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final background =
        theme.brightness == Brightness.light ? cs.primary : cs.surface;
    final foreground =
        theme.brightness == Brightness.light ? cs.onPrimary : cs.onSurface;
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      bottom: bottom,
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 0,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
    );
  }
}

//

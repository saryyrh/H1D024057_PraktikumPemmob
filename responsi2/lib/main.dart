import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    const warmCream = Color(0xFFF5F0E6);
    const softSand = Color(0xFFEAE2D3);
    const borderSand = Color(0xFFD5CCB8);
    const deepLeafGreen = Color(0xFF3E4A3A);
    const earthBrown = Color(0xFF6B4F3A);
    const darkText = Color(0xFF222621);

    final baseTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: warmCream,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: deepLeafGreen,
        secondary: earthBrown,
        surface: softSand,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
        outline: borderSand,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: warmCream,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: softSand,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSand, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepLeafGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );

    return ChangeNotifierProvider(
      create: (_) => WeatherViewModel(),
      child: MaterialApp(
        title: 'Cuaca Nusantara',
        debugShowCheckedModeBanner: false,
        theme: baseTheme.copyWith(
          textTheme: baseTheme.textTheme.apply(
            bodyColor: darkText,
            displayColor: darkText,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

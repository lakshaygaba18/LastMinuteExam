import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ExamApp());
}

class ExamApp extends StatefulWidget {
  const ExamApp({super.key});

  @override
  State<ExamApp> createState() => _ExamAppState();
}

class _ExamAppState extends State<ExamApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final isLoggedIn = supabase.auth.currentUser != null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exam AI',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ===================== LIGHT THEME =====================
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6D28D9),
          secondary: Color(0xFFEC4899),
          surface: Color(0xFFFFFFFF),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0A0A0F),
          titleTextStyle: TextStyle(
            color: Color(0xFF0A0A0F),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // ===================== DARK THEME =====================
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFFEC4899),
          surface: Color(0xFF141420),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),

      home: isLoggedIn
          ? HomeScreen(isDarkMode: isDarkMode, onToggleTheme: toggleTheme)
          : LoginScreen(isDarkMode: isDarkMode, onToggleTheme: toggleTheme),
    );
  }
}
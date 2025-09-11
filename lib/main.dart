import 'package:farmlytics/auth_wrapper.dart';
import 'package:farmlytics/screens/language_selection_screen.dart';
import 'package:farmlytics/screens/onboarding_screen.dart';
import 'package:farmlytics/services/auth_service.dart';
import 'package:farmlytics/services/language_service.dart';
import 'package:farmlytics/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await AuthService.initialize();

  // Initialize Language Service
  await LanguageService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarIconBrightness: Brightness.dark,
    //     statusBarBrightness: Brightness.light,
    //   ),
    // );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Farmer',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'FunnelDisplay',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'FunnelDisplay',
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'FunnelDisplay',
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'FunnelDisplay',
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            fontFamily: 'FunnelDisplay',
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(fontFamily: 'FunnelDisplay'),
          titleSmall: TextStyle(fontFamily: 'FunnelDisplay'),
          bodyLarge: TextStyle(fontFamily: 'FunnelDisplay'),
          bodyMedium: TextStyle(fontFamily: 'FunnelDisplay'),
          bodySmall: TextStyle(fontFamily: 'Helvetica'),
          labelLarge: TextStyle(fontFamily: 'Helvetica'),
          labelMedium: TextStyle(fontFamily: 'Helvetica'),
          labelSmall: TextStyle(fontFamily: 'Helvetica'),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/language-selection': (context) => const LanguageSelectionScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

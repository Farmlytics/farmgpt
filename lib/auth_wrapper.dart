import 'package:flutter/material.dart';
import 'package:farmlytics/screens/auth_screen.dart';
import 'package:farmlytics/screens/home_screen.dart';
import 'package:farmlytics/screens/language_selection_screen.dart';
import 'package:farmlytics/screens/onboarding_screen.dart';
import 'package:farmlytics/splash.dart';
import 'package:farmlytics/services/auth_service.dart';
import 'package:farmlytics/services/language_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _minSplashElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (!mounted) return;
      setState(() {
        _minSplashElapsed = true;
      });
    });
  }

  Future<Map<String, bool>> _getUserStatus() async {
    try {
      final authService = AuthService();
      final isNewUser = await authService.isNewUser();

      return {'isNewUser': isNewUser};
    } catch (e) {
      // If we can't determine status, assume new user for safety
      return {'isNewUser': true};
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final waiting = snapshot.connectionState == ConnectionState.waiting;
        if (waiting || !_minSplashElapsed) {
          return const SplashScreen();
        }

        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return FutureBuilder<Map<String, bool>>(
            future: _getUserStatus(),
            builder: (context, statusSnapshot) {
              if (statusSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              final status = statusSnapshot.data ?? {'isNewUser': true};
              final isNewUser = status['isNewUser'] ?? true;

              if (isNewUser) {
                // New user flow: Language Selection -> Onboarding -> Home
                final currentLanguage = LanguageService.getCurrentLanguage();
                if (currentLanguage == 'en') {
                  // Default language, show language selection first
                  return const LanguageSelectionScreen();
                } else {
                  // Language already selected, go to onboarding
                  return const OnboardingScreen();
                }
              } else {
                // Existing user flow: Language Selection -> Home (skip onboarding)
                final currentLanguage = LanguageService.getCurrentLanguage();
                if (currentLanguage == 'en') {
                  // Default language, show language selection first
                  return const LanguageSelectionScreen();
                } else {
                  // Language already selected, go directly to home
                  return const HomeScreen();
                }
              }
            },
          );
        }
        return const AuthScreen();
      },
    );
  }
}

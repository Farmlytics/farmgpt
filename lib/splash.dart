import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'MainPage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: const Color(0xFFECE1EE),
      splash: Center(
        child: Lottie.asset(
          'assets/animations/plant.json',
          width: 300,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
      nextScreen: const MainPage(),
      duration: 3000,
      splashIconSize: 300,
    );
  }
}

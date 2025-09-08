import 'package:farmlytics/splash.dart';
import 'package:flutter/material.dart';


void main() {
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
          headlineLarge: TextStyle(fontFamily: 'FunnelDisplay', fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontFamily: 'FunnelDisplay', fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontFamily: 'FunnelDisplay', fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontFamily: 'FunnelDisplay', fontWeight: FontWeight.bold),
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
      home: const SplashScreen(),
    );
  }
}

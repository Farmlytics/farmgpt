import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'MainPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set status bar for dark theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    
    // Initialize animations with smoother timing
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Start animations with staggered timing
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _progressController.forward();
      _rotationController.repeat();
    });
    
    // Navigate to main page after 4 seconds
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainPage(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.3),
            radius: 1.2,
            colors: [
              Color(0xFF0A0A0A), // Very dark center
              Color(0xFF000000), // Pure black edges
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Subtle background particles/dots
                ...List.generate(20, (index) {
                  return Positioned(
                    left: (index * 47.3) % screenWidth,
                    top: (index * 83.7) % (screenHeight * 0.6) + 100,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value + (index * 0.5),
                          child: Container(
                            width: 1.5,
                            height: 1.5,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Move content up by reducing this spacer
                      const SizedBox(height: 40),
                      
                      // Modern logo with glassmorphism effect
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: const Color(0xFF1FBA55),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1FBA55).withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.eco_outlined,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // App name with modern typography
                      Text(
                        'FarmGPT',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'FunnelDisplay',
                          color: Colors.white,
                          letterSpacing: -2.0,
                          height: 0.9,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      
                      
                      const SizedBox(height: 50),
                      
                      // Plant animation without border - bigger size
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Lottie.asset(
                          'assets/animations/plant.json',
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                          frameRate: FrameRate.max,
                          options: LottieOptions(
                            enableMergePaths: true,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Modern progress indicator
                      SizedBox(
                        width: 200,
                        child: Column(
                          children: [
                            Container(
                              width: 200,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 200 * _progressAnimation.value,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF1DB954),
                                              Color(0xFF1ED760),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF1DB954).withOpacity(0.5),
                                              blurRadius: 8,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Progress percentage
                            AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return Text(
                                  '${(_progressAnimation.value * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1.0,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

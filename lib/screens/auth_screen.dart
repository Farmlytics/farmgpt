import 'package:flutter/material.dart';
import 'dart:async';
import 'package:farmlytics/services/auth_service.dart';
import 'package:farmlytics/services/language_service.dart';
import 'package:farmlytics/screens/onboarding_screen.dart';
import 'package:farmlytics/screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();

  bool _codeSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isSignUp = true; // Toggle between sign up and sign in
  int _resendSeconds = 0;
  Timer? _resendTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    // Start fade animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final phone = _phoneController.text.trim();

      if (!_codeSent) {
        await authService.signInWithPhone(phone: phone);
        if (mounted) {
          setState(() {
            _codeSent = true;
            _startResendTimer();
          });
        }
      } else {
        await authService.verifyOtp(
          phone: phone,
          token: _otpController.text.trim(),
          name: _isSignUp ? _nameController.text.trim() : null,
        );
        if (mounted) {
          // Determine where to navigate based on user type
          Widget destinationScreen;

          if (_isSignUp) {
            // Always show onboarding for sign up users
            destinationScreen = const OnboardingScreen();
          } else {
            // For sign in users, go directly to home screen
            destinationScreen = const HomeScreen();
          }

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  destinationScreen,
              transitionDuration: const Duration(milliseconds: 800),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.0, 0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        String friendly = message.replaceAll('Exception: ', '');
        if (message.contains('otp_expired')) {
          friendly = 'OTP expired. Tap Resend OTP and enter the new code.';
        } else if (message.contains('Invalid login credentials')) {
          friendly = 'Invalid OTP. Please re-check or resend a new code.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendly), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendSeconds = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendSeconds -= 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        // App Logo/Title with Hero animation
                        Center(
                          child: Column(
                            children: [
                              Hero(
                                tag: 'app_logo',
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.asset(
                                        'assets/icon/icon_splash.png',
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Text(
                                  'farmlytics',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'FunnelDisplay',
                                    color: Colors.white,
                                    letterSpacing: -1.2,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Text(
                                  'AI-Powered Farming Assistant',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Title with animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            _isSignUp
                                ? LanguageService.t('sign_up')
                                : LanguageService.t('sign_in'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontFamily: 'FunnelDisplay',
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Form with animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Name field (only for sign up)
                                if (_isSignUp) ...[
                                  _buildTextField(
                                    controller: _nameController,
                                    label: LanguageService.t('name'),
                                    icon: Icons.person_outlined,
                                    keyboardType: TextInputType.name,
                                    validator: (value) {
                                      if (_isSignUp &&
                                          (value == null || value.isEmpty)) {
                                        return LanguageService.t(
                                          'invalid_name',
                                        );
                                      }
                                      if (_isSignUp && value!.length < 2) {
                                        return 'Name must be at least 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                ],

                                // Phone field
                                _buildTextField(
                                  controller: _phoneController,
                                  label: LanguageService.t('phone_number'),
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return LanguageService.t(
                                        'invalid_phone_number',
                                      );
                                    }
                                    // Normalize to +91 if user did not include country code
                                    final normalized = value.startsWith('+')
                                        ? value
                                        : '+91${value.replaceAll(RegExp(r'[^0-9]'), '')}';
                                    if (!RegExp(
                                      r'^\+?[1-9]\d{7,14}$',
                                    ).hasMatch(normalized)) {
                                      return 'Enter a valid phone number with country code';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 10),

                                // OTP field (after code sent) with animation
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  height: _codeSent ? null : 0,
                                  child: _codeSent
                                      ? Column(
                                          children: [
                                            _buildTextField(
                                              controller: _otpController,
                                              label: LanguageService.t(
                                                'verification_code',
                                              ),
                                              icon: Icons.lock_clock_outlined,
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (value) {
                                                if (!_codeSent) return null;
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return LanguageService.t(
                                                    'invalid_verification_code',
                                                  );
                                                }
                                                if (value.length < 4) {
                                                  return 'OTP seems too short';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),

                                const SizedBox(height: 8),

                                // Auth Button with enhanced styling
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1FBA55),
                                        Color(0xFF1ED760),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF1FBA55,
                                        ).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: _isLoading ? null : _handleAuth,
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                _codeSent
                                                    ? LanguageService.t(
                                                        'verify',
                                                      )
                                                    : (_isSignUp
                                                          ? LanguageService.t(
                                                              'sign_up',
                                                            )
                                                          : LanguageService.t(
                                                              'send_code',
                                                            )),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_codeSent)
                                  TextButton(
                                    onPressed: _isLoading || _resendSeconds > 0
                                        ? null
                                        : () async {
                                            try {
                                              await AuthService()
                                                  .signInWithPhone(
                                                    phone: _phoneController.text
                                                        .trim(),
                                                  );
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('OTP resent'),
                                                  ),
                                                );
                                                _startResendTimer();
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      e.toString().replaceAll(
                                                        'Exception: ',
                                                        '',
                                                      ),
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                    child: Text(
                                      _resendSeconds > 0
                                          ? '${LanguageService.t('resend_code_in')} ${_resendSeconds}${LanguageService.t('seconds')}'
                                          : LanguageService.t('resend_code'),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Fixed bottom section with toggle
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp
                              ? 'Already have an account? '
                              : 'Don\'t have an account? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _codeSent = false;
                              _nameController.clear();
                              _phoneController.clear();
                              _otpController.clear();
                              _resendTimer?.cancel();
                              _resendSeconds = 0;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? LanguageService.t('sign_in')
                                : LanguageService.t('sign_up'),
                            style: const TextStyle(
                              color: Color(0xFF1FBA55),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: const Color(0xFF1FBA55).withOpacity(0.3),
            selectionHandleColor: const Color(0xFF1FBA55),
            cursorColor: const Color(0xFF1FBA55),
          ),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? _obscurePassword : false,
          validator: validator,
          cursorColor: const Color(0xFF1FBA55),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 18),
                Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
                if (label == 'Phone number') ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1FBA55).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF1FBA55).withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '+91',
                      style: TextStyle(
                        color: const Color(0xFF1FBA55).withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white.withOpacity(0.6),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 11,
            ),
            errorStyle: TextStyle(
              color: Colors.red.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

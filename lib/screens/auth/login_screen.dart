// ============================================================
// VibeLab — login_screen.dart
// Sign in with Google or Email/Password.
// Brutalist Dark Aurora aesthetic.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/aurora_background.dart';
import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showForgotPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail(AuthProvider auth) async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) return;

    await auth.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (auth.isAuthenticated && mounted) {
      _navigateToHome();
    }
  }

  Future<void> _signInWithGoogle(AuthProvider auth) async {
    await auth.signInWithGoogle();
    if (auth.isAuthenticated && mounted) {
      _navigateToHome();
    }
  }

  Future<void> _sendForgotPassword(AuthProvider auth) async {
    if (_emailController.text.trim().isEmpty) return;
    await auth.sendPasswordReset(_emailController.text.trim());
    if (mounted) {
      setState(() => _showForgotPassword = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'RESET EMAIL SENT',
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: VibeLabTheme.textDark,
            ),
          ),
          backgroundColor: VibeLabTheme.vibeLime,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLoading = auth.state == AuthState.loading;

        return AuroraBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        // Header
                        Text(
                          'WELCOME\nBACK.',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 24,
                            color: VibeLabTheme.textPrimary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          width: 40,
                          height: 3,
                          color: VibeLabTheme.vibeLime,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Sign in to access your vibes.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: VibeLabTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Error banner
                        if (auth.state == AuthState.error) ...[
                          _ErrorBanner(
                            message: auth.errorMessage,
                            onDismiss: auth.clearError,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Google Sign In Button
                        _GoogleSignInButton(
                          onTap: isLoading
                              ? null
                              : () => _signInWithGoogle(auth),
                          isLoading: isLoading,
                        ),

                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: VibeLabTheme.borderSubtle,
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 8,
                                  color: VibeLabTheme.textHint,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: VibeLabTheme.borderSubtle,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Email field
                        _BrutalistTextField(
                          controller: _emailController,
                          label: 'EMAIL',
                          hint: 'your@email.com',
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 12),

                        // Password field
                        _BrutalistTextField(
                          controller: _passwordController,
                          label: 'PASSWORD',
                          hint: '••••••••',
                          obscureText: _obscurePassword,
                          onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              if (_emailController.text.trim().isEmpty) {
                                setState(
                                        () => _showForgotPassword = true);
                              } else {
                                _sendForgotPassword(auth);
                              }
                            },
                            child: Text(
                              'FORGOT PASSWORD?',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 7,
                                color: VibeLabTheme.vibeLime,
                              ),
                            ),
                          ),
                        ),

                        if (_showForgotPassword) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Enter your email above then tap forgot password.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: VibeLabTheme.textSecondary,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Sign In button
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: isLoading
                                ? null
                                : () => _signInWithEmail(auth),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isLoading
                                    ? VibeLabTheme.vibeLime.withOpacity(0.5)
                                    : VibeLabTheme.vibeLime,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: VibeLabTheme.vibeLime,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: VibeLabTheme.textDark,
                                  ),
                                )
                                    : Text(
                                  'SIGN IN',
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 11,
                                    color: VibeLabTheme.textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'NEW HERE? ',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 8,
                                color: VibeLabTheme.textHint,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'CREATE ACCOUNT',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 8,
                                  color: VibeLabTheme.vibeLime,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------
// Google Sign In Button
// ----------------------------------------------------------
class _GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const _GoogleSignInButton({this.onTap, required this.isLoading});

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _hovered
                ? VibeLabTheme.cosmicInkCard
                : VibeLabTheme.cosmicInkLighter,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered
                  ? VibeLabTheme.borderNormal
                  : VibeLabTheme.borderSubtle,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google G icon
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: CustomPaint(painter: _GoogleIconPainter()),
              ),
              const SizedBox(width: 12),
              Text(
                'CONTINUE WITH GOOGLE',
                style: GoogleFonts.pressStart2p(
                  fontSize: 9,
                  color: VibeLabTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Simple Google G painter
// ----------------------------------------------------------
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.3,
      2.0,
      true,
      paint,
    );

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.7,
      1.6,
      true,
      paint,
    );

    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.3,
      0.9,
      true,
      paint,
    );

    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      4.2,
      0.8,
      true,
      paint,
    );

    // White center
    paint.color = VibeLabTheme.cosmicInk;
    canvas.drawCircle(center, radius * 0.55, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------
// Brutalist text field
// ----------------------------------------------------------
class _BrutalistTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final VoidCallback? onToggleObscure;

  const _BrutalistTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 8,
            color: VibeLabTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            color: VibeLabTheme.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: onToggleObscure != null
                ? GestureDetector(
              onTap: onToggleObscure,
              child: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: VibeLabTheme.textHint,
                size: 18,
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// Error banner
// ----------------------------------------------------------
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.red.shade300,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: Colors.red, size: 16),
          ),
        ],
      ),
    );
  }
}
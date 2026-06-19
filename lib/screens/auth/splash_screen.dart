// ============================================================
// VibeLab — splash_screen.dart
// App launch screen. Checks auth state and routes accordingly.
// Shows animated logo while Firebase Auth initializes.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/aurora_background.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Check auth after animation
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation + Firebase to initialize
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Wait until auth state is determined
    if (authProvider.state == AuthState.initial) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      _navigateTo(const HomeScreen());
    } else {
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Flask logo
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CustomPaint(
                          painter: _SplashFlaskPainter(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // App name
                      Text(
                        'VIBELAB',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 28,
                          color: VibeLabTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Lime underline
                      Container(
                        width: 48,
                        height: 3,
                        color: VibeLabTheme.vibeLime,
                      ),

                      const SizedBox(height: 40),

                      // Loading indicator
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: VibeLabTheme.vibeLime.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SplashFlaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = VibeLabTheme.vibeLime
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final fillPaint = Paint()
      ..color = VibeLabTheme.vibeLime.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = VibeLabTheme.vibeLime.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(w * 0.35, h * 0.05);
    path.lineTo(w * 0.65, h * 0.05);
    path.lineTo(w * 0.65, h * 0.38);
    path.lineTo(w * 0.92, h * 0.80);
    path.lineTo(w * 0.92, h * 0.94);
    path.lineTo(w * 0.08, h * 0.94);
    path.lineTo(w * 0.08, h * 0.80);
    path.lineTo(w * 0.35, h * 0.38);
    path.close();

    canvas.drawPath(path, glowPaint);

    final liquidPath = Path();
    liquidPath.moveTo(w * 0.08, h * 0.94);
    liquidPath.lineTo(w * 0.92, h * 0.94);
    liquidPath.lineTo(w * 0.92, h * 0.78);
    liquidPath.lineTo(w * 0.08, h * 0.78);
    liquidPath.close();
    canvas.drawPath(liquidPath, fillPaint);

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// ============================================================
// VibeLab — loading_overlay.dart (UI Refresh)
// Pixel font loading messages. Animated SVG flask.
// Brutalist aesthetic — no emojis in chrome.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'aurora_background.dart';

class LoadingOverlay extends StatefulWidget {
  final String message;
  const LoadingOverlay({super.key, required this.message});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _liquidController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _liquidAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _liquidController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _liquidAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _liquidController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated flask
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: AnimatedBuilder(
                        animation: _liquidAnimation,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _AnimatedFlaskPainter(
                              liquidLevel: _liquidAnimation.value,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Loading message — pixel font
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.message,
                    key: ValueKey(widget.message),
                    style: GoogleFonts.pressStart2p(
                      fontSize: 11,
                      color: VibeLabTheme.textPrimary,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Brutalist progress bar
              _BrutalistProgressBar(),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Animated flask with rising liquid
// ----------------------------------------------------------
class _AnimatedFlaskPainter extends CustomPainter {
  final double liquidLevel;
  _AnimatedFlaskPainter({required this.liquidLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = VibeLabTheme.vibeLime
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final liquidPaint = Paint()
      ..color = VibeLabTheme.vibeLime.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = VibeLabTheme.vibeLime.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Flask outline path
    final flaskPath = Path();
    flaskPath.moveTo(w * 0.35, h * 0.05);
    flaskPath.lineTo(w * 0.65, h * 0.05);
    flaskPath.lineTo(w * 0.65, h * 0.38);
    flaskPath.lineTo(w * 0.92, h * 0.80);
    flaskPath.lineTo(w * 0.92, h * 0.94);
    flaskPath.lineTo(w * 0.08, h * 0.94);
    flaskPath.lineTo(w * 0.08, h * 0.80);
    flaskPath.lineTo(w * 0.35, h * 0.38);
    flaskPath.close();

    // Glow fill
    canvas.drawPath(flaskPath, glowPaint);

    // Liquid fill — level animates
    final liquidTop = h * 0.94 - (liquidLevel * h * 0.55);
    final liquidPath = Path();
    liquidPath.moveTo(w * 0.08, h * 0.94);
    liquidPath.lineTo(w * 0.92, h * 0.94);
    liquidPath.lineTo(w * 0.92, max(liquidTop, h * 0.80));

    if (liquidTop < h * 0.80) {
      // Liquid has risen into the neck
      final neckRatio = (h * 0.80 - liquidTop) / (h * 0.80 - h * 0.38);
      final neckLeft = w * 0.08 + (neckRatio * (w * 0.35 - w * 0.08));
      final neckRight = w * 0.92 - (neckRatio * (w * 0.92 - w * 0.65));
      liquidPath.lineTo(neckRight, liquidTop);
      liquidPath.lineTo(neckLeft, liquidTop);
      liquidPath.lineTo(w * 0.08, h * 0.80);
    } else {
      liquidPath.lineTo(w * 0.08, max(liquidTop, h * 0.80));
    }
    liquidPath.close();
    canvas.drawPath(liquidPath, liquidPaint);

    // Flask stroke on top
    canvas.drawPath(flaskPath, strokePaint);

    // Bubbles that float up
    final bubblePaint = Paint()
      ..color = VibeLabTheme.vibeLime
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(w * 0.35, h * 0.72), 2.5, bubblePaint);
    canvas.drawCircle(Offset(w * 0.60, h * 0.65), 1.8, bubblePaint);
    canvas.drawCircle(Offset(w * 0.45, h * 0.58), 1.5, bubblePaint);
  }

  double max(double a, double b) => a > b ? a : b;

  @override
  bool shouldRepaint(covariant _AnimatedFlaskPainter old) =>
      old.liquidLevel != liquidLevel;
}

// ----------------------------------------------------------
// Brutalist progress bar — chunky, sharp, lime
// ----------------------------------------------------------
class _BrutalistProgressBar extends StatefulWidget {
  @override
  State<_BrutalistProgressBar> createState() => _BrutalistProgressBarState();
}

class _BrutalistProgressBarState extends State<_BrutalistProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: 200,
          height: 6,
          decoration: BoxDecoration(
            border: Border.all(
              color: VibeLabTheme.borderNormal,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _controller.value,
            child: Container(
              decoration: BoxDecoration(
                color: VibeLabTheme.vibeLime,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        );
      },
    );
  }
}
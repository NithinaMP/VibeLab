// ============================================================
// VibeLab — aurora_background.dart
// The signature visual of VibeLab.
// An animated gradient background that slowly morphs
// between aurora colors based on the current mood.
// This runs on EVERY screen — it's what makes VibeLab
// feel alive instead of static.
// ============================================================

import 'package:flutter/material.dart';
import '../core/theme.dart';

class AuroraBackground extends StatefulWidget {
  final List<Color>? colors; // Pass mood colors or use defaults
  final Widget child;

  const AuroraBackground({
    super.key,
    this.colors,
    required this.child,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  late Animation<Alignment> _topAlignment;
  late Animation<Alignment> _bottomAlignment;
  late Animation<double> _opacityAnimation;

  List<Color> get _colors =>
      widget.colors ?? VibeLabTheme.defaultAurora;

  @override
  void initState() {
    super.initState();

    // Primary aurora drift — slow and majestic
    _controller1 = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    // Secondary drift — slightly different timing for organic feel
    _controller2 = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse animation — subtle breathing effect
    _controller3 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _topAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topRight,
          end: Alignment.centerRight,
        ),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller1,
      curve: Curves.easeInOut,
    ));

    _bottomAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomLeft,
          end: Alignment.centerLeft,
        ),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller2,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(begin: 0.15, end: 0.30).animate(
      CurvedAnimation(parent: _controller3, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller1, _controller2, _controller3]),
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            color: VibeLabTheme.cosmicInk,
          ),
          child: Stack(
            children: [
              // Aurora layer 1 — primary color blob
              Positioned.fill(
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: _topAlignment.value,
                        radius: 1.2,
                        colors: [
                          _colors[0].withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Aurora layer 2 — secondary color blob
              Positioned.fill(
                child: Opacity(
                  opacity: _opacityAnimation.value * 0.8,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: _bottomAlignment.value,
                        radius: 1.0,
                        colors: [
                          _colors[1].withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Aurora layer 3 — tertiary accent, centered
              Positioned.fill(
                child: Opacity(
                  opacity: _opacityAnimation.value * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          _colors.length > 2
                              ? _colors[2].withOpacity(0.3)
                              : _colors[0].withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Subtle grid overlay — gives depth
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: CustomPaint(
                    painter: _GridPainter(),
                  ),
                ),
              ),

              // The actual screen content
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------
// Subtle dot grid that gives the background depth
// Very faint — just enough to feel textured
// ----------------------------------------------------------
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
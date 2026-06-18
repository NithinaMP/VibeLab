// ============================================================
// VibeLab — loading_overlay.dart
// The loading screen that shows while generation happens.
// Cycles through VibeLab's personality messages.
// The aurora background shifts colors during loading —
// even before results arrive the app is "feeling" the vibe.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'aurora_background.dart';

class LoadingOverlay extends StatefulWidget {
  final String message;

  const LoadingOverlay({
    super.key,
    required this.message,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
              // Pulsing lab flask icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: VibeLabTheme.auroraPurple.withOpacity(0.5),
                          width: 1.5,
                        ),
                        color: VibeLabTheme.cosmicInkLighter,
                      ),
                      child: const Center(
                        child: Text(
                          '🧪',
                          style: TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Loading message with fade transition
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  widget.message,
                  key: ValueKey(widget.message),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: VibeLabTheme.textPrimary,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Subtle progress dots
              _ProgressDots(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatefulWidget {
  @override
  State<_ProgressDots> createState() => _ProgressDotsState();
}

class _ProgressDotsState extends State<_ProgressDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index / 3;
            final progress = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (progress < 0.5)
                ? progress * 2
                : (1.0 - progress) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity.clamp(0.2, 1.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: VibeLabTheme.auroraPurple,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
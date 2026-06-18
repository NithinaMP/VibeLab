// ============================================================
// VibeLab — home_screen.dart
// The entry point. Vast, dark, alive.
// The aurora breathes. One input. Total confidence.
// Reacts to VibeState — shows loading overlay during generation.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/vibe_provider.dart';
import '../widgets/aurora_background.dart';
import '../widgets/vibe_input.dart';
import '../widgets/loading_overlay.dart';
import 'studio_screen.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VibeProvider>(
      builder: (context, provider, _) {
        // Navigate to studio when generation succeeds
        if (provider.state == VibeState.success &&
            provider.currentVibe != null) {
          // Use addPostFrameCallback to avoid build-phase navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, animation, __) => const StudioScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          });
        }

        // Show loading overlay during generation
        if (provider.state == VibeState.loading) {
          return LoadingOverlay(message: provider.loadingMessage);
        }

        return AuroraBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // ------------------------------------------
                  // Top navigation bar
                  // ------------------------------------------
                  _TopBar(),

                  // ------------------------------------------
                  // Main content — centered hero
                  // ------------------------------------------
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),

                            // App icon
                            const Text(
                              '🧪',
                              style: TextStyle(fontSize: 52),
                            ),

                            const SizedBox(height: 16),

                            // App name
                            Text(
                              'VibeLab',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                                color: VibeLabTheme.textPrimary,
                                letterSpacing: -2,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Tagline
                            Text(
                              'Input a mood. Get a synchronized creative universe.',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: VibeLabTheme.textSecondary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 48),

                            // Main input
                            const VibeInput(),

                            const SizedBox(height: 24),

                            // Error message if something failed
                            if (provider.state == VibeState.error)
                              _ErrorBanner(message: provider.errorMessage),

                            const SizedBox(height: 40),

                            // Feature pills
                            _FeaturePills(),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------
// Top navigation bar
// ----------------------------------------------------------
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              const Text('🧪', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'VibeLab',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: VibeLabTheme.textPrimary,
                ),
              ),
            ],
          ),

          // Gallery button
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GalleryScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.grid_view_rounded,
              size: 16,
              color: VibeLabTheme.textSecondary,
            ),
            label: Text(
              'Gallery',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: VibeLabTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Error banner
// ----------------------------------------------------------
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.red.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Feature pills showing what the app generates
// ----------------------------------------------------------
class _FeaturePills extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      ('🖼️', 'AI Poster'),
      ('😂', 'Meme Kit'),
      ('🎵', 'Mood Audio'),
      ('✨', 'Brand Memory'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: features.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: VibeLabTheme.borderSubtle),
            color: VibeLabTheme.cosmicInkLighter,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(f.$1, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                f.$2,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: VibeLabTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
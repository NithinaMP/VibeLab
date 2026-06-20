// ============================================================
// VibeLab — poster_card.dart
// Renders the AI-generated image with text overlays.
// Works in both POSTER mode and MEME mode.
// The RepaintBoundary key is used for PNG export.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme.dart';
import '../models/vibe_bundle.dart';

class PosterCard extends StatelessWidget {
  final VibeBundle vibe;
  final bool isPosterMode;
  final GlobalKey repaintKey; // Used for PNG export

  const PosterCard({
    super.key,
    required this.vibe,
    required this.isPosterMode,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: isPosterMode ? 0.75 : 1.0, // Portrait for poster, square for meme
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ------------------------------------------
              // Background image from Pollinations.ai
              // ------------------------------------------
              vibe.imageUrl != null
                  ? CachedNetworkImage(
                imageUrl: vibe.imageUrl!,
                fit: BoxFit.cover,
                httpHeaders: const {'Connection': 'keep-alive'},
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (context, url) => _ImageShimmer(),
                errorWidget: (context, url, error) => _ImageError(),
              )
                  : _ImageShimmer(),

              // ------------------------------------------
              // Dark gradient overlay so text is readable
              // ------------------------------------------
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isPosterMode
                          ? [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.75),
                      ]
                          : [
                        Colors.black.withOpacity(0.55),
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // ------------------------------------------
              // Text overlays — different layout per mode
              // ------------------------------------------
              if (isPosterMode)
                _PosterOverlay(vibe: vibe)
              else
                _MemeOverlay(vibe: vibe),

              // ------------------------------------------
              // VibeLab watermark — bottom right corner
              // ------------------------------------------
              Positioned(
                bottom: 12,
                right: 14,
                child: Text(
                  'made with VibeLab 🧪',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
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
// Poster mode text overlay — headline at bottom
// ----------------------------------------------------------
class _PosterOverlay extends StatelessWidget {
  final VibeBundle vibe;
  const _PosterOverlay({required this.vibe});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mood tag pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: VibeLabTheme.auroraPurple.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                vibe.moodTag.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Main headline
            Text(
              vibe.posterHeadline,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 6),

            // Subheadline
            Text(
              vibe.posterSubheadline,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withOpacity(0.75),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Meme mode text overlay — top and bottom text
// ----------------------------------------------------------
class _MemeOverlay extends StatelessWidget {
  final VibeBundle vibe;
  const _MemeOverlay({required this.vibe});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top text
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Text(
            vibe.memeTopText,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
              shadows: [
                const Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
                const Shadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(-1, -1),
                ),
              ],
            ),
          ),
        ),

        // Bottom text
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Text(
            vibe.memeBottomText,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
              shadows: [
                const Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
                const Shadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(-1, -1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// Shimmer placeholder while image loads
// ----------------------------------------------------------
class _ImageShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: VibeLabTheme.cosmicInkLighter,
      highlightColor: VibeLabTheme.cosmicInkLight,
      child: Container(color: VibeLabTheme.cosmicInkLighter),
    );
  }
}

// ----------------------------------------------------------
// Error state if image fails to load
// ----------------------------------------------------------
class _ImageError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: VibeLabTheme.cosmicInkLighter,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎨', style: TextStyle(fontSize: 40)),
            SizedBox(height: 8),
            Text(
              'Image loading...',
              style: TextStyle(
                color: VibeLabTheme.textHint,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
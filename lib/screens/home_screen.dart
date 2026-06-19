// ============================================================
// VibeLab — home_screen.dart (UI Refresh)
// Dark Aurora Brutalist aesthetic.
// Pixel font headings, lime accents, sharp borders.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vibelab/providers/auth_provider.dart';
import 'package:vibelab/screens/auth/profile_screen.dart';
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
        if (provider.state == VibeState.success &&
            provider.currentVibe != null) {
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

        if (provider.state == VibeState.loading) {
          return LoadingOverlay(message: provider.loadingMessage);
        }

        return AuroraBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  _TopBar(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),

                            // ----------------------------------
                            // Logo mark — geometric SVG flask
                            // ----------------------------------
                            _LogoMark(),

                            const SizedBox(height: 24),

                            // ----------------------------------
                            // App name — pixel font, oversized
                            // ----------------------------------
                            Text(
                              'VIBELAB',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 36,
                                color: VibeLabTheme.textPrimary,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Lime underline accent
                            Container(
                              width: 60,
                              height: 3,
                              color: VibeLabTheme.vibeLime,
                            ),

                            const SizedBox(height: 20),

                            // Tagline — Inter for readability
                            Text(
                              'Input a mood.\nGet a synchronized creative universe.',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: VibeLabTheme.textSecondary,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 48),

                            // Main input
                            const VibeInput(),

                            const SizedBox(height: 24),

                            // Error message
                            if (provider.state == VibeState.error)
                              _ErrorBanner(message: provider.errorMessage),

                            const SizedBox(height: 40),

                            // Feature tags
                            _FeatureTags(),

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
// Top navigation bar — brutalist style
// ----------------------------------------------------------
// class _TopBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Logo text
//           Text(
//             'VIBELAB',
//             style: GoogleFonts.pressStart2p(
//               fontSize: 12,
//               color: VibeLabTheme.textPrimary,
//             ),
//           ),
//
//           // Gallery nav button — brutalist outlined
//           GestureDetector(
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(builder: (_) => const GalleryScreen()),
//               );
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 14,
//                 vertical: 8,
//               ),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: VibeLabTheme.borderNormal,
//                   width: 2,
//                 ),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 'GALLERY',
//                 style: GoogleFonts.pressStart2p(
//                   fontSize: 9,
//                   color: VibeLabTheme.textSecondary,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// ============================================================
// VibeLab — home_screen.dart (Updated — profile button added)
// Replace the _TopBar class only. Rest stays the same.
// ============================================================

// ----------------------------------------------------------
// REPLACE _TopBar with this version:
// ----------------------------------------------------------

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Text(
            'VIBELAB',
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: VibeLabTheme.textPrimary,
            ),
          ),

          // Right side nav
          Row(
            children: [
              // Gallery button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GalleryScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: VibeLabTheme.borderSubtle,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'GALLERY',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 9,
                      color: VibeLabTheme.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Profile button
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: VibeLabTheme.vibeLime.withOpacity(0.5),
                          width: 2,
                        ),
                        color: VibeLabTheme.cosmicInkLighter,
                      ),
                      child: auth.photoUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.network(
                          auth.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              auth.displayName.isNotEmpty
                                  ? auth.displayName[0].toUpperCase()
                                  : 'V',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 12,
                                color: VibeLabTheme.vibeLime,
                              ),
                            ),
                          ),
                        ),
                      )
                          : Center(
                        child: Text(
                          auth.displayName.isNotEmpty
                              ? auth.displayName[0].toUpperCase()
                              : 'V',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 12,
                            color: VibeLabTheme.vibeLime,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ----------------------------------------------------------
// Geometric SVG flask logo mark
// ----------------------------------------------------------
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(
        painter: _FlaskPainter(),
      ),
    );
  }
}

class _FlaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = VibeLabTheme.vibeLime
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square; // Brutalist — square caps

    final fillPaint = Paint()
      ..color = VibeLabTheme.vibeLime.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Flask body path
    final path = Path();
    path.moveTo(w * 0.35, h * 0.05); // top left of neck
    path.lineTo(w * 0.65, h * 0.05); // top right of neck
    path.lineTo(w * 0.65, h * 0.38); // right neck bottom
    path.lineTo(w * 0.90, h * 0.78); // right shoulder
    path.lineTo(w * 0.90, h * 0.92); // right bottom
    path.lineTo(w * 0.10, h * 0.92); // left bottom
    path.lineTo(w * 0.10, h * 0.78); // left shoulder
    path.lineTo(w * 0.35, h * 0.38); // left neck bottom
    path.close();

    // Fill
    canvas.drawPath(path, fillPaint);
    // Stroke
    canvas.drawPath(path, strokePaint);

    // Liquid inside flask — lime fill
    final liquidPaint = Paint()
      ..color = VibeLabTheme.vibeLime.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final liquidPath = Path();
    liquidPath.moveTo(w * 0.15, h * 0.78);
    liquidPath.lineTo(w * 0.85, h * 0.78);
    liquidPath.lineTo(w * 0.90, h * 0.92);
    liquidPath.lineTo(w * 0.10, h * 0.92);
    liquidPath.close();
    canvas.drawPath(liquidPath, liquidPaint);

    // Bubbles — two small circles
    canvas.drawCircle(
      Offset(w * 0.38, h * 0.68),
      3,
      strokePaint..color = VibeLabTheme.vibeLime,
    );
    canvas.drawCircle(
      Offset(w * 0.58, h * 0.60),
      2,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
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
                fontSize: 12,
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
// Feature tags — no emojis, clean text pills
// ----------------------------------------------------------
class _FeatureTags extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      'AI POSTER',
      'MEME KIT',
      'MOOD AUDIO',
      'BRAND MEMORY',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: features.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: VibeLabTheme.borderSubtle, width: 1),
            color: VibeLabTheme.cosmicInkLighter,
          ),
          child: Text(
            f,
            style: GoogleFonts.pressStart2p(
              fontSize: 8,
              color: VibeLabTheme.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
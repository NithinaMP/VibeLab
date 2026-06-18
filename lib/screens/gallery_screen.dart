// ============================================================
// VibeLab — gallery_screen.dart
// Pinterest-style masonry grid of all saved vibes.
// Loads from Firestore. Each card shows the poster image
// with the mood tag and headline.
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme.dart';
import '../providers/vibe_provider.dart';
import '../models/vibe_bundle.dart';
import '../widgets/aurora_background.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    // Load gallery when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VibeProvider>().loadGallery();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VibeProvider>(
      builder: (context, provider, _) {
        return AuroraBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  _GalleryTopBar(),

                  // Content
                  Expanded(
                    child: provider.isGalleryLoading
                        ? _LoadingGrid()
                        : provider.gallery.isEmpty
                        ? _EmptyState()
                        : _GalleryGrid(vibes: provider.gallery),
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
// Gallery top bar
// ----------------------------------------------------------
class _GalleryTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: VibeLabTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Your Gallery',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: VibeLabTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            'saved vibes',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: VibeLabTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Masonry grid of saved vibes
// ----------------------------------------------------------
class _GalleryGrid extends StatelessWidget {
  final List<VibeBundle> vibes;
  const _GalleryGrid({required this.vibes});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount =
    MediaQuery.of(context).size.width > 900 ? 4 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: vibes.length,
        itemBuilder: (context, index) {
          return _GalleryCard(vibe: vibes[index]);
        },
      ),
    );
  }
}

// ----------------------------------------------------------
// Individual gallery card
// ----------------------------------------------------------
class _GalleryCard extends StatefulWidget {
  final VibeBundle vibe;
  const _GalleryCard({required this.vibe});

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? VibeLabTheme.auroraPurple.withOpacity(0.5)
                : VibeLabTheme.borderSubtle,
          ),
          boxShadow: _hovered
              ? [
            BoxShadow(
              color: VibeLabTheme.auroraPurple.withOpacity(0.1),
              blurRadius: 20,
            )
          ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image
              widget.vibe.imageUrl != null
                  ? CachedNetworkImage(
                imageUrl: widget.vibe.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: VibeLabTheme.cosmicInkLighter,
                  highlightColor: VibeLabTheme.cosmicInkLight,
                  child: Container(
                    height: 180,
                    color: VibeLabTheme.cosmicInkLighter,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: VibeLabTheme.cosmicInkLighter,
                  child: const Center(
                    child: Text('🎨', style: TextStyle(fontSize: 32)),
                  ),
                ),
              )
                  : Container(
                height: 180,
                color: VibeLabTheme.cosmicInkLighter,
              ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.vibe.posterHeadline,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.vibe.moodTag,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
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
    );
  }
}

// ----------------------------------------------------------
// Loading shimmer grid
// ----------------------------------------------------------
class _LoadingGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: VibeLabTheme.cosmicInkLighter,
            highlightColor: VibeLabTheme.cosmicInkLight,
            child: Container(
              height: index.isEven ? 200 : 160,
              decoration: BoxDecoration(
                color: VibeLabTheme.cosmicInkLighter,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------
// Empty gallery state
// ----------------------------------------------------------
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎨', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'No vibes saved yet',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: VibeLabTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a vibe and save it to see it here.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: VibeLabTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Create Your First Vibe 🧪'),
          ),
        ],
      ),
    );
  }
}
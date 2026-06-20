// ============================================================
// VibeLab — gallery_screen.dart (Complete - UI Refresh Applied)
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
                  _GalleryTopBar(galleryCount: provider.gallery.length),
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
// Gallery top bar — brutalist
// ----------------------------------------------------------
class _GalleryTopBar extends StatelessWidget {
  final int galleryCount;
  const _GalleryTopBar({required this.galleryCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VibeLabTheme.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: VibeLabTheme.borderNormal,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '< BACK',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: VibeLabTheme.textSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Page title
          Text(
            'GALLERY',
            style: GoogleFonts.pressStart2p(
              fontSize: 14,
              color: VibeLabTheme.textPrimary,
            ),
          ),

          const Spacer(),

          // Vibe count
          Text(
            '$galleryCount VIBES',
            style: GoogleFonts.pressStart2p(
              fontSize: 8,
              color: VibeLabTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Masonry grid
// ----------------------------------------------------------
class _GalleryGrid extends StatelessWidget {
  final List<VibeBundle> vibes;
  const _GalleryGrid({required this.vibes});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount =
    MediaQuery.of(context).size.width > 900 ? 4 : 2;

    return Padding(
      padding: const EdgeInsets.all(16),
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
// Gallery card
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
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => _ImageViewerDialog(vibe: widget.vibe),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered
                  ? VibeLabTheme.vibeLime
                  : VibeLabTheme.borderSubtle,
              width: _hovered ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
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
                    child: Center(
                      child: Text(
                        'IMG',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10,
                          color: VibeLabTheme.textHint,
                        ),
                      ),
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
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.vibe.posterHeadline,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 9,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.vibe.moodTag.toUpperCase(),
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7,
                            color: VibeLabTheme.vibeLime,
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
}

// ----------------------------------------------------------
// Loading shimmer grid
// ----------------------------------------------------------
class _LoadingGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------
// Empty state
// ----------------------------------------------------------
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: VibeLabTheme.borderNormal,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'EMPTY',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: VibeLabTheme.textHint,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'NO VIBES YET',
            style: GoogleFonts.pressStart2p(
              fontSize: 14,
              color: VibeLabTheme.textPrimary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Generate a vibe and save it.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: VibeLabTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 28),

          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: VibeLabTheme.vibeLime,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: VibeLabTheme.vibeLime,
                  width: 2,
                ),
              ),
              child: Text(
                'CREATE FIRST VIBE',
                style: GoogleFonts.pressStart2p(
                  fontSize: 9,
                  color: VibeLabTheme.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ImageViewerDialog extends StatelessWidget {
  final VibeBundle vibe;
  const _ImageViewerDialog({required this.vibe});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Full image
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: vibe.imageUrl ?? '',
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                height: 300,
                color: VibeLabTheme.cosmicInkLighter,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: VibeLabTheme.vibeLime,
                  ),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: VibeLabTheme.cosmicInk,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: VibeLabTheme.borderNormal,
                    width: 2,
                  ),
                ),
                child: Text(
                  'X',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: VibeLabTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),

          // Details at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vibe.posterHeadline,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vibe.posterSubheadline,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vibe.moodTag.toUpperCase(),
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: VibeLabTheme.vibeLime,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
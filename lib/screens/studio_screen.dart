// ============================================================
// VibeLab — studio_screen.dart
// The main results screen. Split into visual and audio panels.
// Left: poster/meme card with mode toggle.
// Right: audio player + copy details + export actions.
// Responsive: stacks vertically on mobile/narrow screens.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:universal_html/html.dart' as html;
import '../core/theme.dart';
import '../providers/vibe_provider.dart';
import '../widgets/aurora_background.dart';
import '../widgets/poster_card.dart';
import '../widgets/audio_player_widget.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  // RepaintBoundary key — used to capture the poster as PNG
  final GlobalKey _repaintKey = GlobalKey();
  bool _isExporting = false;

  // ----------------------------------------------------------
  // Export poster as PNG
  // Uses Flutter's RenderRepaintBoundary to capture the widget
  // and triggers a browser download — zero cost, fully local
  // ----------------------------------------------------------
  // Future<void> _exportAsPng() async {
  //   setState(() => _isExporting = true);
  //
  //   try {
  //     final boundary = _repaintKey.currentContext?.findRenderObject()
  //     as RenderRepaintBoundary?;
  //
  //     if (boundary == null) return;
  //
  //     // Capture at 2x pixel ratio for high resolution export
  //     final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
  //     final ByteData? byteData =
  //     await image.toByteData(format: ui.ImageByteFormat.png);
  //
  //     if (byteData == null) return;
  //
  //     // Trigger browser download
  //     final blob = html.Blob([byteData.buffer.asUint8List()]);
  //     final url = html.Url.createObjectUrlFromBlob(blob);
  //     html.AnchorElement(href: url)
  //       ..setAttribute('download', 'vibelab_poster.png')
  //       ..click();
  //     html.Url.revokeObjectUrl(url);
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Export failed: $e')),
  //       );
  //     }
  //   } finally {
  //     setState(() => _isExporting = false);
  //   }
  // }


  Future<void> _exportAsPng() async {
    setState(() => _isExporting = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find render boundary');
      }

      // Capture at 2x for high resolution
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) throw Exception('Could not convert to PNG');

      final bytes = byteData.buffer.asUint8List();

      // Web-safe download using dart:html directly
      final blob = html.Blob([bytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'vibelab_${DateTime.now().millisecondsSinceEpoch}.png';

      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Poster downloaded! 🧪',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: VibeLabTheme.auroraPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VibeProvider>();
    final vibe = provider.currentVibe;

    if (vibe == null) {
      // Should never happen but safe fallback
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final moodColors = VibeLabTheme.getAuroraForMood(vibe.moodTag);
    final isWide = MediaQuery.of(context).size.width > 900;

    return AuroraBackground(
      colors: moodColors, // Aurora shifts to match the vibe mood
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // ------------------------------------------
              // Top bar
              // ------------------------------------------
              _StudioTopBar(vibe: vibe),

              // ------------------------------------------
              // Main content
              // ------------------------------------------
              Expanded(
                child: isWide
                    ? _WideLayout(
                  vibe: vibe,
                  repaintKey: _repaintKey,
                  isExporting: _isExporting,
                  onExport: _exportAsPng,
                  provider: provider,
                )
                    : _NarrowLayout(
                  vibe: vibe,
                  repaintKey: _repaintKey,
                  isExporting: _isExporting,
                  onExport: _exportAsPng,
                  provider: provider,
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
// Wide layout (desktop) — side by side
// ----------------------------------------------------------
class _WideLayout extends StatelessWidget {
  final vibe;
  final GlobalKey repaintKey;
  final bool isExporting;
  final VoidCallback onExport;
  final VibeProvider provider;

  const _WideLayout({
    required this.vibe,
    required this.repaintKey,
    required this.isExporting,
    required this.onExport,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Poster/Meme card
          Expanded(
            flex: 5,
            child: PosterCard(
              vibe: vibe,
              isPosterMode: provider.isPosterMode,
              repaintKey: repaintKey,
            ),
          ),

          const SizedBox(width: 24),

          // Right: Controls panel
          Expanded(
            flex: 4,
            child: _ControlsPanel(
              vibe: vibe,
              isExporting: isExporting,
              onExport: onExport,
              provider: provider,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Narrow layout (mobile/tablet) — stacked
// ----------------------------------------------------------
class _NarrowLayout extends StatelessWidget {
  final vibe;
  final GlobalKey repaintKey;
  final bool isExporting;
  final VoidCallback onExport;
  final VibeProvider provider;

  const _NarrowLayout({
    required this.vibe,
    required this.repaintKey,
    required this.isExporting,
    required this.onExport,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          PosterCard(
            vibe: vibe,
            isPosterMode: provider.isPosterMode,
            repaintKey: repaintKey,
          ),
          const SizedBox(height: 20),
          _ControlsPanel(
            vibe: vibe,
            isExporting: isExporting,
            onExport: onExport,
            provider: provider,
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Controls panel — right side of studio
// ----------------------------------------------------------
class _ControlsPanel extends StatelessWidget {
  final vibe;
  final bool isExporting;
  final VoidCallback onExport;
  final VibeProvider provider;

  const _ControlsPanel({
    required this.vibe,
    required this.isExporting,
    required this.onExport,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vibe prompt display
          Text(
            '"${vibe.userPrompt}"',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: VibeLabTheme.textPrimary,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Color palette: ${vibe.colorPalette}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: VibeLabTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // Poster / Meme mode toggle
          _ModeToggle(
            isPosterMode: provider.isPosterMode,
            onToggle: provider.toggleMode,
          ),

          const SizedBox(height: 20),

          // Audio player
          if (vibe.audioUrl != null)
            VibeAudioPlayer(
              audioUrl: vibe.audioUrl!,
              moodTag: vibe.moodTag,
            ),

          const SizedBox(height: 20),

          // Copy details card
          _CopyDetails(vibe: vibe),

          const SizedBox(height: 20),

          // Action buttons
          _ActionButtons(
            isExporting: isExporting,
            isSaved: vibe.isSaved,
            onExport: onExport,
            onSave: () => provider.saveToGallery(),
            onNewVibe: () {
              provider.resetToHome();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Poster / Meme mode toggle
// ----------------------------------------------------------
class _ModeToggle extends StatelessWidget {
  final bool isPosterMode;
  final VoidCallback onToggle;

  const _ModeToggle({required this.isPosterMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: VibeLabTheme.cosmicInkLighter,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VibeLabTheme.borderSubtle),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: '🖼️  Poster',
            isSelected: isPosterMode,
            onTap: !isPosterMode ? onToggle : null,
          ),
          _ToggleOption(
            label: '😂  Meme',
            isSelected: !isPosterMode,
            onTap: isPosterMode ? onToggle : null,
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected
                ? VibeLabTheme.auroraPurple.withOpacity(0.2)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
                color: VibeLabTheme.auroraPurple.withOpacity(0.5))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight:
              isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? VibeLabTheme.textPrimary
                  : VibeLabTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Generated copy details card
// ----------------------------------------------------------
class _CopyDetails extends StatelessWidget {
  final vibe;
  const _CopyDetails({required this.vibe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VibeLabTheme.cosmicInkLighter,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VibeLabTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generated Copy',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: VibeLabTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _CopyRow(label: 'Headline', value: vibe.posterHeadline),
          _CopyRow(label: 'Subline', value: vibe.posterSubheadline),
          _CopyRow(label: 'Meme Top', value: vibe.memeTopText),
          _CopyRow(label: 'Meme Bot', value: vibe.memeBottomText),
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  const _CopyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: VibeLabTheme.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: VibeLabTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Action buttons — export, save, new vibe
// ----------------------------------------------------------
class _ActionButtons extends StatelessWidget {
  final bool isExporting;
  final bool isSaved;
  final VoidCallback onExport;
  final VoidCallback onSave;
  final VoidCallback onNewVibe;

  const _ActionButtons({
    required this.isExporting,
    required this.isSaved,
    required this.onExport,
    required this.onSave,
    required this.onNewVibe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Export PNG button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isExporting ? null : onExport,
            icon: isExporting
                ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.download_rounded, size: 18),
            label: Text(isExporting ? 'Exporting...' : 'Download Poster PNG'),
          ),
        ),

        const SizedBox(height: 10),

        // Save to gallery button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isSaved ? null : onSave,
            style: OutlinedButton.styleFrom(
              foregroundColor: VibeLabTheme.auroraTeal,
              side: BorderSide(
                color: isSaved
                    ? VibeLabTheme.borderSubtle
                    : VibeLabTheme.auroraTeal.withOpacity(0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              isSaved ? Icons.check_rounded : Icons.bookmark_border_rounded,
              size: 18,
            ),
            label: Text(
              isSaved ? 'Saved to Gallery ✓' : 'Save to Gallery',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // New vibe button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: onNewVibe,
            icon: const Text('🧪', style: TextStyle(fontSize: 14)),
            label: Text(
              'Create New Vibe',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: VibeLabTheme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// Studio top bar
// ----------------------------------------------------------
class _StudioTopBar extends StatelessWidget {
  final vibe;
  const _StudioTopBar({required this.vibe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.read<VibeProvider>().resetToHome();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: VibeLabTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Studio Canvas',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: VibeLabTheme.textPrimary,
            ),
          ),
          const Spacer(),
          // Mood tag badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: VibeLabTheme.auroraPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: VibeLabTheme.auroraPurple.withOpacity(0.3),
              ),
            ),
            child: Text(
              '${vibe.moodTag} vibe',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: VibeLabTheme.auroraPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
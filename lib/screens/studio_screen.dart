// ============================================================
// VibeLab — studio_screen.dart (Complete - UI Refresh Applied)
// ============================================================
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../widgets/editable_copy_details.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:universal_html/html.dart' as html;
import '../core/theme.dart';
import '../providers/vibe_provider.dart';
import '../models/vibe_bundle.dart';
import '../widgets/aurora_background.dart';
import '../widgets/poster_card.dart';
import '../widgets/audio_player_widget.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isExporting = false;

  // Future<void> _exportAsPng() async {
  //   setState(() => _isExporting = true);
  //
  //   try {
  //     final boundary = _repaintKey.currentContext?.findRenderObject()
  //     as RenderRepaintBoundary?;
  //
  //     if (boundary == null) throw Exception('Could not find render boundary');
  //
  //     final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
  //     final ByteData? byteData =
  //     await image.toByteData(format: ui.ImageByteFormat.png);
  //
  //     if (byteData == null) throw Exception('Could not convert to PNG');
  //
  //     final bytes = byteData.buffer.asUint8List();
  //     final blob = html.Blob([bytes], 'image/png');
  //     final url = html.Url.createObjectUrlFromBlob(blob);
  //     final anchor = html.document.createElement('a') as html.AnchorElement
  //       ..href = url
  //       ..style.display = 'none'
  //       ..download = 'vibelab_${DateTime.now().millisecondsSinceEpoch}.png';
  //
  //     html.document.body!.children.add(anchor);
  //     anchor.click();
  //     html.document.body!.children.remove(anchor);
  //     html.Url.revokeObjectUrl(url);
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Poster downloaded!',
  //             style: GoogleFonts.pressStart2p(
  //               fontSize: 9,
  //               color: VibeLabTheme.textDark,
  //             ),
  //           ),
  //           backgroundColor: VibeLabTheme.vibeLime,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(4),
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Export failed: $e',
  //             style: GoogleFonts.inter(color: Colors.white),
  //           ),
  //           backgroundColor: Colors.red.shade800,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isExporting = false);
  //   }
  // }
  Future<void> _exportAsPng() async {
    setState(() => _isExporting = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;

      if (boundary == null) throw Exception('Could not find render boundary');

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) throw Exception('Could not convert to PNG');

      // Platform-safe download
      if (kIsWeb) {
        // Web browser download
        final bytes = byteData.buffer.asUint8List();
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
      } else {
        // Mobile — save to gallery using path_provider
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/vibelab_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(byteData.buffer.asUint8List());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Saved to: $filePath',
                style: GoogleFonts.inter(fontSize: 11),
              ),
              backgroundColor: VibeLabTheme.vibeLime,
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'POSTER DOWNLOADED',
              style: GoogleFonts.pressStart2p(
                fontSize: 9,
                color: VibeLabTheme.textDark,
              ),
            ),
            backgroundColor: VibeLabTheme.vibeLime,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final moodColors = VibeLabTheme.getAuroraForMood(vibe.moodTag);
    final isWide = MediaQuery.of(context).size.width > 900;

    return AuroraBackground(
      colors: moodColors,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _StudioTopBar(vibe: vibe),
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
// Wide layout
// ----------------------------------------------------------
class _WideLayout extends StatelessWidget {
  final VibeBundle vibe;
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
          Expanded(
            flex: 5,
            child: PosterCard(
              vibe: vibe,
              isPosterMode: provider.isPosterMode,
              repaintKey: repaintKey,
            ),
          ),
          const SizedBox(width: 24),
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
// Narrow layout
// ----------------------------------------------------------
class _NarrowLayout extends StatelessWidget {
  final VibeBundle vibe;
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
// Controls panel
// ----------------------------------------------------------
class _ControlsPanel extends StatelessWidget {
  final VibeBundle vibe;
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
          Text(
            '"${vibe.userPrompt}"',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VibeLabTheme.textPrimary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            vibe.colorPalette,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: VibeLabTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          _ModeToggle(
            isPosterMode: provider.isPosterMode,
            onToggle: provider.toggleMode,
          ),
          const SizedBox(height: 20),
          if (vibe.audioUrl != null)
            VibeAudioPlayer(
              audioUrl: vibe.audioUrl!,
              moodTag: vibe.moodTag,
            ),
          const SizedBox(height: 20),
          // _CopyDetails(vibe: vibe),
          EditableCopyDetails(
            vibe: vibe,
            onVibeUpdated: (updatedVibe) {
              provider.updateCurrentVibe(updatedVibe);
            },
          ),
          const SizedBox(height: 20),
          _ActionButtons(
            isExporting: isExporting,
            isSaved: vibe.isSaved,
            onExport: onExport,
            onSave: () => provider.saveToGallery(),
            // onNewVibe: () {
            //   Navigator.of(context).pop();
            //   Future.delayed(const Duration(milliseconds: 300), () {
            //     provider.resetToHome();
            //   });
            // },
            onNewVibe: () {
              context.read<VibeProvider>().resetToHome();
              Navigator.of(context).pop();
            },          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Mode toggle
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
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: VibeLabTheme.borderSubtle, width: 2),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'POSTER',
            isSelected: isPosterMode,
            onTap: !isPosterMode ? onToggle : null,
          ),
          _ToggleOption(
            label: 'MEME',
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
            borderRadius: BorderRadius.circular(4),
            color: isSelected
                ? VibeLabTheme.vibeLime.withOpacity(0.15)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
              color: VibeLabTheme.vibeLime.withOpacity(0.5),
              width: 2,
            )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: isSelected
                  ? VibeLabTheme.vibeLime
                  : VibeLabTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Copy details
// ----------------------------------------------------------
class _CopyDetails extends StatelessWidget {
  final VibeBundle vibe;
  const _CopyDetails({required this.vibe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VibeLabTheme.cosmicInkLighter,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: VibeLabTheme.borderSubtle, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GENERATED COPY',
            style: GoogleFonts.pressStart2p(
              fontSize: 8,
              color: VibeLabTheme.textSecondary,
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
// Action buttons — brutalist style
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
        // Download PNG — lime brutalist
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: isExporting ? null : onExport,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isExporting
                    ? VibeLabTheme.vibeLime.withOpacity(0.5)
                    : VibeLabTheme.vibeLime,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: VibeLabTheme.vibeLime, width: 2),
              ),
              child: Center(
                child: isExporting
                    ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: VibeLabTheme.textDark,
                  ),
                )
                    : Text(
                  'DOWNLOAD PNG',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: VibeLabTheme.textDark,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Save to gallery
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: isSaved ? null : onSave,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSaved
                      ? VibeLabTheme.borderSubtle
                      : VibeLabTheme.auroraTeal,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  isSaved ? 'SAVED' : 'SAVE TO GALLERY',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: isSaved
                        ? VibeLabTheme.textHint
                        : VibeLabTheme.auroraTeal,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // New vibe
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: onNewVibe,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'NEW VIBE',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: VibeLabTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// Studio top bar — brutalist
// ----------------------------------------------------------
class _StudioTopBar extends StatelessWidget {
  final VibeBundle vibe;
  const _StudioTopBar({required this.vibe});

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
          GestureDetector(
            // onTap: () {
            //   Navigator.of(context).pop();
            //   Future.delayed(const Duration(milliseconds: 300), () {
            //     context.read<VibeProvider>().resetToHome();
            //   });
            // },
            onTap: () {
              context.read<VibeProvider>().resetToHome();
              Navigator.of(context).pop();
            },
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

          Text(
            'STUDIO',
            style: GoogleFonts.pressStart2p(
              fontSize: 14,
              color: VibeLabTheme.textPrimary,
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: VibeLabTheme.vibeLime.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: VibeLabTheme.vibeLime.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Text(
              vibe.moodTag.toUpperCase(),
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: VibeLabTheme.vibeLime,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ============================================================
// VibeLab — editable_copy_details.dart
// Replaces _CopyDetails in studio_screen.dart
// Users can edit headline, subheadline, meme texts directly.
// Changes reflect instantly on the poster/meme card.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/vibe_bundle.dart';

class EditableCopyDetails extends StatefulWidget {
  final VibeBundle vibe;
  final Function(VibeBundle) onVibeUpdated;

  const EditableCopyDetails({
    super.key,
    required this.vibe,
    required this.onVibeUpdated,
  });

  @override
  State<EditableCopyDetails> createState() => _EditableCopyDetailsState();
}

class _EditableCopyDetailsState extends State<EditableCopyDetails> {
  late TextEditingController _headlineController;
  late TextEditingController _subheadlineController;
  late TextEditingController _memeTopController;
  late TextEditingController _memeBottomController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _headlineController =
        TextEditingController(text: widget.vibe.posterHeadline);
    _subheadlineController =
        TextEditingController(text: widget.vibe.posterSubheadline);
    _memeTopController =
        TextEditingController(text: widget.vibe.memeTopText);
    _memeBottomController =
        TextEditingController(text: widget.vibe.memeBottomText);
  }

  @override
  void didUpdateWidget(covariant EditableCopyDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset controllers if vibe changed (new generation)
    if (oldWidget.vibe.id != widget.vibe.id) {
      _disposeControllers();
      _initControllers();
      setState(() => _isEditing = false);
    }
  }

  void _disposeControllers() {
    _headlineController.dispose();
    _subheadlineController.dispose();
    _memeTopController.dispose();
    _memeBottomController.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _applyChanges() {
    // Create updated vibe with user's custom text
    final updatedVibe = VibeBundle(
      id: widget.vibe.id,
      userPrompt: widget.vibe.userPrompt,
      createdAt: widget.vibe.createdAt,
      visualPrompt: widget.vibe.visualPrompt,
      moodTag: widget.vibe.moodTag,
      posterHeadline: _headlineController.text.trim().isEmpty
          ? widget.vibe.posterHeadline
          : _headlineController.text.trim().toUpperCase(),
      posterSubheadline: _subheadlineController.text.trim().isEmpty
          ? widget.vibe.posterSubheadline
          : _subheadlineController.text.trim(),
      memeTopText: _memeTopController.text.trim().isEmpty
          ? widget.vibe.memeTopText
          : _memeTopController.text.trim().toUpperCase(),
      memeBottomText: _memeBottomController.text.trim().isEmpty
          ? widget.vibe.memeBottomText
          : _memeBottomController.text.trim().toUpperCase(),
      colorPalette: widget.vibe.colorPalette,
      fontMood: widget.vibe.fontMood,
      imageUrl: widget.vibe.imageUrl,
      audioUrl: widget.vibe.audioUrl,
      isSaved: widget.vibe.isSaved,
    );

    widget.onVibeUpdated(updatedVibe);
    setState(() => _isEditing = false);
  }

  void _resetToOriginal() {
    _headlineController.text = widget.vibe.posterHeadline;
    _subheadlineController.text = widget.vibe.posterSubheadline;
    _memeTopController.text = widget.vibe.memeTopText;
    _memeBottomController.text = widget.vibe.memeBottomText;
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VibeLabTheme.cosmicInkLighter,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _isEditing
              ? VibeLabTheme.vibeLime.withOpacity(0.5)
              : VibeLabTheme.borderSubtle,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GENERATED COPY',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: VibeLabTheme.textSecondary,
                ),
              ),

              // Edit / Apply toggle button
              GestureDetector(
                onTap: () {
                  if (_isEditing) {
                    _applyChanges();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _isEditing
                        ? VibeLabTheme.vibeLime
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _isEditing
                          ? VibeLabTheme.vibeLime
                          : VibeLabTheme.borderNormal,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'APPLY' : 'EDIT',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7,
                      color: _isEditing
                          ? VibeLabTheme.textDark
                          : VibeLabTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Hint text when editing
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Edit any field. Tap APPLY to update the poster.',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: VibeLabTheme.vibeLime.withOpacity(0.7),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Editable fields
          _EditableField(
            label: 'HEADLINE',
            controller: _headlineController,
            isEditing: _isEditing,
            isUppercase: true,
          ),

          const SizedBox(height: 10),

          _EditableField(
            label: 'SUBLINE',
            controller: _subheadlineController,
            isEditing: _isEditing,
          ),

          const SizedBox(height: 10),

          _EditableField(
            label: 'MEME TOP',
            controller: _memeTopController,
            isEditing: _isEditing,
            isUppercase: true,
          ),

          const SizedBox(height: 10),

          _EditableField(
            label: 'MEME BOT',
            controller: _memeBottomController,
            isEditing: _isEditing,
            isUppercase: true,
          ),

          // Reset button — only shown when editing
          if (_isEditing) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _resetToOriginal,
              child: Text(
                'RESET TO AI VERSION',
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: VibeLabTheme.textHint,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Single editable field — shows text or input based on mode
// ----------------------------------------------------------
class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final bool isUppercase;

  const _EditableField({
    required this.label,
    required this.controller,
    required this.isEditing,
    this.isUppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
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

        // Value or input
        Expanded(
          child: isEditing
              ? TextField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: VibeLabTheme.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              filled: true,
              fillColor: VibeLabTheme.cosmicInkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: VibeLabTheme.vibeLime,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: VibeLabTheme.vibeLime.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: VibeLabTheme.vibeLime,
                  width: 1.5,
                ),
              ),
            ),
            maxLines: isUppercase ? 1 : 2,
            textCapitalization: isUppercase
                ? TextCapitalization.characters
                : TextCapitalization.sentences,
          )
              : Text(
            controller.text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: VibeLabTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
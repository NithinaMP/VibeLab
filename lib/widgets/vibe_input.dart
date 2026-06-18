// ============================================================
// VibeLab — vibe_input.dart (UI Refresh)
// Brutalist input field — sharp corners, thick border.
// Lime Generate button. Text-only preset tags.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/vibe_provider.dart';

class VibeInput extends StatefulWidget {
  const VibeInput({super.key});

  @override
  State<VibeInput> createState() => _VibeInputState();
}

class _VibeInputState extends State<VibeInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _generate(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<VibeProvider>().generateVibe(text);
  }

  void _usePreset(String prompt) {
    _controller.text = prompt;
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --------------------------------------------------
        // Brutalist input field
        // --------------------------------------------------
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 680 : double.infinity,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _isFocused
                    ? VibeLabTheme.vibeLime
                    : VibeLabTheme.borderNormal,
                width: 2,
              ),
              color: VibeLabTheme.cosmicInkLighter,
              // Lime glow when focused
              boxShadow: _isFocused
                  ? [
                BoxShadow(
                  color: VibeLabTheme.vibeLime.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                )
              ]
                  : [],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: GoogleFonts.inter(
                      color: VibeLabTheme.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'describe your vibe...',
                      hintStyle: GoogleFonts.inter(
                        color: VibeLabTheme.textHint,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onSubmitted: (_) => _generate(context),
                  ),
                ),
                const SizedBox(width: 8),

                // Lime brutalist generate button
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: _GenerateButton(onTap: () => _generate(context)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // --------------------------------------------------
        // Preset tags — text only, no emojis
        // --------------------------------------------------
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 680 : double.infinity,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: VibeLabConstants.vibePresets.map((preset) {
              // Strip emoji from label — show text only
              final rawLabel = preset['label']!;
              final textOnly = rawLabel
                  .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
                  .trim();

              return _PresetTag(
                label: textOnly.isEmpty ? rawLabel : textOnly,
                onTap: () => _usePreset(preset['prompt']!),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// Lime brutalist generate button
// ----------------------------------------------------------
class _GenerateButton extends StatefulWidget {
  final VoidCallback onTap;
  const _GenerateButton({required this.onTap});

  @override
  State<_GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<_GenerateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _hovered
                  ? VibeLabTheme.vibeLimeDark
                  : VibeLabTheme.vibeLime,
              border: Border.all(
                color: _hovered
                    ? VibeLabTheme.vibeLimeDark
                    : VibeLabTheme.vibeLime,
                width: 2,
              ),
            ),
            child: Text(
              'GENERATE',
              style: GoogleFonts.pressStart2p(
                fontSize: 9,
                color: VibeLabTheme.textDark,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Preset tag — brutalist pill, text only
// ----------------------------------------------------------
class _PresetTag extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetTag({required this.label, required this.onTap});

  @override
  State<_PresetTag> createState() => _PresetTagState();
}

class _PresetTagState extends State<_PresetTag> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered
                  ? VibeLabTheme.vibeLime
                  : VibeLabTheme.borderSubtle,
              width: _hovered ? 2 : 1,
            ),
            color: _hovered
                ? VibeLabTheme.vibeLime.withOpacity(0.08)
                : VibeLabTheme.cosmicInkLighter,
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.pressStart2p(
              fontSize: 7,
              color: _hovered
                  ? VibeLabTheme.vibeLime
                  : VibeLabTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
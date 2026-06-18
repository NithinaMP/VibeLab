// ============================================================
// VibeLab — vibe_input.dart
// The central input bar on the home screen.
// Clean, confident, minimal — just like premium apps.
// Includes preset tags below for quick selection.
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --------------------------------------------------
        // Main input field
        // --------------------------------------------------
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: BoxConstraints(
            maxWidth: isWide ? 680 : double.infinity,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isFocused
                  ? VibeLabTheme.auroraPurple
                  : VibeLabTheme.borderSubtle,
              width: _isFocused ? 1.5 : 1.0,
            ),
            color: VibeLabTheme.cosmicInkLighter,
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: VibeLabTheme.auroraPurple.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 0,
              )
            ]
                : [],
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: GoogleFonts.inter(
                    color: VibeLabTheme.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText:
                    'Describe a mood, vibe, or theme...',
                    hintStyle: GoogleFonts.inter(
                      color: VibeLabTheme.textHint,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                  ),
                  onSubmitted: (_) => _generate(context),
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),

              // Generate button inside the input field
              Padding(
                padding: const EdgeInsets.all(6),
                child: _GenerateButton(
                  onTap: () => _generate(context),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --------------------------------------------------
        // Preset vibe tags
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
              return _VibeTag(
                label: preset['label']!,
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
// The glowing generate button
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [VibeLabTheme.auroraPurple, VibeLabTheme.auroraTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: VibeLabTheme.auroraPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🧪', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Generate',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
// Preset vibe tag pill
// ----------------------------------------------------------
class _VibeTag extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _VibeTag({required this.label, required this.onTap});

  @override
  State<_VibeTag> createState() => _VibeTagState();
}

class _VibeTagState extends State<_VibeTag> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? VibeLabTheme.auroraPurple
                  : VibeLabTheme.borderSubtle,
              width: 1,
            ),
            color: _hovered
                ? VibeLabTheme.auroraPurple.withOpacity(0.1)
                : VibeLabTheme.cosmicInkLighter,
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _hovered
                  ? VibeLabTheme.textPrimary
                  : VibeLabTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
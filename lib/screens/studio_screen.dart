// ============================================================
// VibeLab — studio_screen.dart (UI Refresh — top bar only)
// Replace only the _StudioTopBar class and _ActionButtons.
// Rest of studio_screen.dart stays the same from Drop 2.
// ============================================================

// ----------------------------------------------------------
// REPLACE _StudioTopBar with this:
// ----------------------------------------------------------

class _StudioTopBar extends StatelessWidget {
  final vibe;
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
          // Back button — brutalist
          GestureDetector(
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

          // Page title
          Text(
            'STUDIO',
            style: GoogleFonts.pressStart2p(
              fontSize: 14,
              color: VibeLabTheme.textPrimary,
            ),
          ),

          const Spacer(),

          // Mood badge — lime accent
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

// ----------------------------------------------------------
// REPLACE _ActionButtons with this:
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
        // Download button — lime brutalist
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
                border: Border.all(
                  color: VibeLabTheme.vibeLime,
                  width: 2,
                ),
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

        // Save to gallery — outlined brutalist
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

        // New vibe — ghost button
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
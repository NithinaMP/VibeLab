// ============================================================
// VibeLab — audio_player.dart
// Minimal, beautiful audio player for the studio screen.
// Shows mood tag, plays the matched audio stem on loop.
// Live waveform visualizer reacts to playback state.
// ============================================================

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../core/theme.dart';

class VibeAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String moodTag;

  const VibeAudioPlayer({
    super.key,
    required this.audioUrl,
    required this.moodTag,
  });

  @override
  State<VibeAudioPlayer> createState() => _VibeAudioPlayerState();
}

class _VibeAudioPlayerState extends State<VibeAudioPlayer>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  late AnimationController _waveController;
  bool _isPlaying = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();

    // Waveform animation controller
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _initAudio();

    // Listen to player state changes
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
        if (_isPlaying) {
          _waveController.repeat();
        } else {
          _waveController.stop();
        }
      }
    });
  }

  Future<void> _initAudio() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop); // Loop forever
      await _player.setSourceUrl(widget.audioUrl);
      setState(() => _isLoading = false);

      // Auto-play when ready
      await _player.resume();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auroraColors = VibeLabTheme.getAuroraForMood(widget.moodTag);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VibeLabTheme.cosmicInkLighter,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VibeLabTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: auroraColors[0].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: auroraColors[0].withOpacity(0.4),
                  ),
                ),
                child: Text(
                  '🎵 ${widget.moodTag.toUpperCase()} STEM',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: auroraColors[0],
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: VibeLabTheme.auroraPurple,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Waveform visualizer
          SizedBox(
            height: 48,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WaveformPainter(
                    progress: _waveController.value,
                    isPlaying: _isPlaying,
                    color: auroraColors[0],
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play / Pause button
              GestureDetector(
                onTap: _isLoading ? null : _togglePlayback,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [auroraColors[0], auroraColors[1]],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: auroraColors[0].withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Loop indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mood Stem',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: VibeLabTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '∞ seamless loop',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: VibeLabTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Waveform painter — animated bars that react to playback
// ----------------------------------------------------------
class _WaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final Color color;

  _WaveformPainter({
    required this.progress,
    required this.isPlaying,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final barCount = 32;
    final barWidth = size.width / barCount;
    final random = Random(42); // Fixed seed for consistent shape

    for (int i = 0; i < barCount; i++) {
      final baseHeight = (random.nextDouble() * 0.6 + 0.2) * size.height;

      // When playing, bars animate up and down
      final animatedHeight = isPlaying
          ? baseHeight *
          (0.6 +
              0.4 *
                  sin((progress * 2 * pi) + (i * 0.4)))
          : baseHeight * 0.3;

      final x = i * barWidth + barWidth / 2;
      final halfHeight = animatedHeight / 2;

      // Draw bar centered vertically
      canvas.drawLine(
        Offset(x, size.height / 2 - halfHeight),
        Offset(x, size.height / 2 + halfHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.progress != progress || old.isPlaying != isPlaying;
}
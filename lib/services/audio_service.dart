// ============================================================
// VibeLab — audio_service.dart
// Matches the mood_tag from Gemini to a curated audio stem
// stored in Firebase Storage. Returns the download URL.
//
// WHY THIS APPROACH:
// Real-time AI music generation (MusicGen) is unreliable on
// free tiers — slow, inconsistent, often broken.
// Curated high-quality stems matched intelligently by Gemini
// gives a better user experience every single time.
// ============================================================

import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants.dart';

class AudioService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Cache URLs so we don't hit Firebase Storage repeatedly
  // for the same mood stem
  final Map<String, String> _urlCache = {};

  // ----------------------------------------------------------
  // getAudioUrlForMood
  // Takes the mood_tag from VibeBundle and returns the
  // Firebase Storage download URL for the matching stem.
  //
  // The stems must be uploaded to Firebase Storage at path:
  // /audio_stems/lofi_chill.mp3
  // /audio_stems/hype_energy.mp3
  // etc. (see constants.dart for full list)
  // ----------------------------------------------------------
  Future<String> getAudioUrlForMood(String moodTag) async {
    // Return cached URL if we already fetched this mood
    if (_urlCache.containsKey(moodTag)) {
      return _urlCache[moodTag]!;
    }

    // Get the filename for this mood
    final fileName = VibeLabConstants.audioStems[moodTag.toLowerCase()]
        ?? VibeLabConstants.audioStems['chill']!; // fallback to chill

    try {
      // Get the download URL from Firebase Storage
      final ref = _storage.ref().child(
        '${VibeLabConstants.audioStemsPath}/$fileName',
      );

      final url = await ref.getDownloadURL();

      // Cache it for future requests
      _urlCache[moodTag] = url;

      return url;
    } catch (e) {
      throw Exception('Audio stem not found for mood "$moodTag": $e\n'
          'Make sure you uploaded the audio stems to Firebase Storage.\n'
          'See constants.dart for the required file names.');
    }
  }

  // ----------------------------------------------------------
  // preloadAllStems
  // Call this on app startup to cache all stem URLs
  // so there's zero delay when generating vibes
  // ----------------------------------------------------------
  Future<void> preloadAllStems() async {
    for (final moodTag in VibeLabConstants.audioStems.keys) {
      try {
        await getAudioUrlForMood(moodTag);
      } catch (_) {
        // Don't crash if a stem is missing — just skip it
        // The app will try to fetch it on-demand later
      }
    }
  }

  // ----------------------------------------------------------
  // clearCache
  // Call if Storage URLs expire (they're valid for ~7 days)
  // ----------------------------------------------------------
  void clearCache() => _urlCache.clear();
}
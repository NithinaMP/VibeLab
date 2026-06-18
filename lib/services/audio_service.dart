// ============================================================
// VibeLab — audio_service.dart (Updated for Drop 3)
// Audio served directly from GitHub raw URLs.
// No Firebase Storage needed — simpler, faster, truly free.
// ============================================================

import '../core/constants.dart';

class AudioService {
  // Simple URL cache — avoids repeated map lookups
  final Map<String, String> _urlCache = {};

  // ----------------------------------------------------------
  // getAudioUrlForMood
  // No async needed anymore — URL is directly in constants.
  // Kept as Future for API compatibility with VibeProvider.
  // ----------------------------------------------------------
  Future<String> getAudioUrlForMood(String moodTag) async {
    if (_urlCache.containsKey(moodTag)) {
      return _urlCache[moodTag]!;
    }

    final url = VibeLabConstants.audioStems[moodTag.toLowerCase()]
        ?? VibeLabConstants.audioStems['chill']!;

    _urlCache[moodTag] = url;
    return url;
  }

  // ----------------------------------------------------------
  // preloadAllStems
  // Just warms the cache — no network calls needed
  // since URLs are hardcoded constants
  // ----------------------------------------------------------
  Future<void> preloadAllStems() async {
    for (final moodTag in VibeLabConstants.audioStems.keys) {
      _urlCache[moodTag] = VibeLabConstants.audioStems[moodTag]!;
    }
  }

  void clearCache() => _urlCache.clear();
}
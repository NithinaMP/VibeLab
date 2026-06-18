// ============================================================
// VibeLab — constants.dart
// ONE place for every API config in the entire app.
// Audio now served from GitHub raw URLs — zero Firebase cost.
// ============================================================

import 'secrets.dart';

class VibeLabConstants {
  VibeLabConstants._();

  // ----------------------------------------------------------
  // GEMINI API (Creative Director)
  // Key lives in secrets.dart — never hardcode here
  // ----------------------------------------------------------
  static const String geminiApiKey = Secrets.geminiApiKey;
  static const String geminiModel = 'gemini-2.5-flash-lite-preview-06-17';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // ----------------------------------------------------------
  // POLLINATIONS.AI (Image Generation)
  // ----------------------------------------------------------
  static const String pollinationsBaseUrl =
      'https://image.pollinations.ai/prompt';
  static const String pollinationsReferrer = 'vibelab.app';

  static const int imageWidth = 1024;
  static const int imageHeight = 1024;

  // ----------------------------------------------------------
  // FIREBASE COLLECTIONS
  // ----------------------------------------------------------
  static const String vibesCollection = 'vibes';
  static const String usersCollection = 'users';

  // ----------------------------------------------------------
  // AUDIO STEMS — GitHub Raw URLs
  // Served from your public vibelab-assets repo.
  // Replace YOUR_GITHUB_USERNAME with your actual username.
  // ----------------------------------------------------------
  static const String _audioBase =
      'https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/vibelab-assets/main/audio';

  static const Map<String, String> audioStems = {
    'chill': '$_audioBase/lofi_chill.mp3',
    'hype': '$_audioBase/hype_energy.mp3',
    'dark': '$_audioBase/dark_ambient.mp3',
    'retro': '$_audioBase/synthwave_retro.mp3',
    'nature': '$_audioBase/nature_calm.mp3',
    'cyberpunk': '$_audioBase/cyberpunk_glitch.mp3',
    'romantic': '$_audioBase/romantic_soft.mp3',
    'corporate': '$_audioBase/corporate_upbeat.mp3',
  };

  // ----------------------------------------------------------
  // LOADING MESSAGES
  // ----------------------------------------------------------
  static const List<String> loadingMessages = [
    'vibelab is cooking... 🧪',
    'vibehaus is building... 🏠',
    'vibecheck in progress... ✅',
    'summoning your aesthetic... ✨',
    'the aurora feels your vibe... 🌌',
    'mixing the perfect palette... 🎨',
    'tuning into your frequency... 📡',
  ];

  // ----------------------------------------------------------
  // VIBE PRESETS
  // ----------------------------------------------------------
  static const List<Map<String, String>> vibePresets = [
    {'label': '🌧️ Rainy Tokyo', 'prompt': 'Rainy Tokyo at 2AM, neon reflections'},
    {'label': '🔥 Hype Fest', 'prompt': 'High energy college music festival Friday night'},
    {'label': '☕ Lo-fi Study', 'prompt': 'Cozy lo-fi study session in a warm café'},
    {'label': '🤖 Cyberpunk', 'prompt': 'Cyberpunk city, glitch aesthetic, neon green'},
    {'label': '🌊 Kerala Monsoon', 'prompt': 'Kerala monsoon nostalgia, earthy greens, rain'},
    {'label': '🎮 Retro Arcade', 'prompt': '90s retro arcade tournament, pixel art vibes'},
    {'label': '🌅 Golden Hour', 'prompt': 'Golden hour sunset, warm and cinematic'},
    {'label': '🎸 Indie Night', 'prompt': 'Indie music night, moody stage lights, vintage'},
  ];
}
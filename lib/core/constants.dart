// ============================================================
// VibeLab — constants.dart
// ONE place for every API key and config in the entire app.
// When a key changes, you change it HERE only.
// ============================================================

import 'package:vibelab/core/secrets.dart';

class VibeLabConstants {
VibeLabConstants._(); // prevent instantiation

// ----------------------------------------------------------
// GEMINI API (Creative Director)
// Get your free key at: https://aistudio.google.com
// We use Flash-Lite: 1000 free requests/day
// ----------------------------------------------------------
  static const String geminiApiKey = Secrets.geminiApiKey;

  static const String geminiModel = 'gemini-2.5-flash-lite-preview-06-17';
static const String geminiBaseUrl =
    'https://generativelanguage.googleapis.com/v1beta/models';

// ----------------------------------------------------------
// POLLINATIONS.AI (Image Generation)
// Register free at: https://auth.pollinations.ai
// to remove watermarks and improve rate limits
// ----------------------------------------------------------
static const String pollinationsBaseUrl = 'https://image.pollinations.ai/prompt';
static const String pollinationsReferrer = 'vibelab.app';

// Image dimensions for poster output
static const int imageWidth = 1024;
static const int imageHeight = 1024;

// ----------------------------------------------------------
// FIREBASE COLLECTIONS
// Consistent naming prevents typos across the app
// ----------------------------------------------------------
static const String vibesCollection = 'vibes';
static const String usersCollection = 'users';

// ----------------------------------------------------------
// FIREBASE STORAGE PATHS
// ----------------------------------------------------------
static const String audioStemsPath = 'audio_stems';
static const String savedPostersPath = 'saved_posters';

// ----------------------------------------------------------
// AUDIO STEMS
// These are the curated mood-matched audio files you upload
// to Firebase Storage. File names must match exactly.
// Upload these files to Firebase Storage under /audio_stems/
// Get free stems from: https://freemusicarchive.org
// or https://www.looperman.com
// ----------------------------------------------------------
static const Map<String, String> audioStems = {
  'chill':
  'https://raw.githubusercontent.com/NithinaMP/vibelab-assets/main/audio/lofi_chill.mp3',

  'hype':
  'https://raw.githubusercontent.com/NithinaMP/vibelab-assets/main/audio/hype_energy.mp3',

  'dark':
  'https://raw.githubusercontent.com/NithinaMP/vibelab-assets/main/audio/dark_ambient.mp3',


  // 'chill': 'lofi_chill.mp3',
  // 'hype': 'hype_energy.mp3',
  // 'dark': 'dark_ambient.mp3',
  'retro': 'https://raw.githubusercontent.com/NithinaMP/vibelab-assets/main/audio/synthwave_retro.mp3',

  // 'synthwave_retro.mp3',
  'nature':  'https://raw.githubusercontent.com/NithinaMP/vibelab-assets/main/audio/nature_calm.mp3',

  // 'nature_calm.mp3',
  'cyberpunk':  'https://raw.githubusercontent.com/NithinaMP/vibelab-assets/main/audio/cyberpunk_glitch.mp3',

  // 'cyberpunk_glitch.mp3',
  'romantic':   'https://raw.githubusercontent.com/NithinaMP/vibelab-assets/main/audio/romantic_soft.mp3',

  // 'romantic_soft.mp3',
  'corporate':   'https://raw.githubusercontent.com/NithinaMP/vibelab-assets/main/audio/corporate_upbeat.mp3',

  // 'corporate_upbeat.mp3',
};

// ----------------------------------------------------------
// LOADING MESSAGES
// VibeLab's personality lives here
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
// Quick-select tags shown below the input bar
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
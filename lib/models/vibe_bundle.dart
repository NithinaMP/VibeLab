// ============================================================
// VibeLab — vibe_bundle.dart
// This is the single data object that flows through the
// entire app. Gemini creates it. Everything else consumes it.
// ============================================================

class VibeBundle {
  // Core identity
  final String id;                // Firestore document ID
  final String userPrompt;        // What the user typed
  final DateTime createdAt;

  // From Gemini Creative Director
  final String visualPrompt;      // Fed to Pollinations.ai
  final String moodTag;           // Maps to aurora color + audio stem
  final String posterHeadline;    // Big text on poster
  final String posterSubheadline; // Smaller poster text
  final String memeTopText;       // Meme top text
  final String memeBottomText;    // Meme bottom text
  final String colorPalette;      // e.g. "purple, teal, dark"
  final String fontMood;          // e.g. "bold", "elegant", "glitchy"

  // Generated assets (filled after API calls complete)
  final String? imageUrl;         // Pollinations.ai result URL
  final String? audioUrl;         // Firebase Storage audio stem URL

  // UI state
  final bool isSaved;             // Has user saved to gallery

  const VibeBundle({
    required this.id,
    required this.userPrompt,
    required this.createdAt,
    required this.visualPrompt,
    required this.moodTag,
    required this.posterHeadline,
    required this.posterSubheadline,
    required this.memeTopText,
    required this.memeBottomText,
    required this.colorPalette,
    required this.fontMood,
    this.imageUrl,
    this.audioUrl,
    this.isSaved = false,
  });

  // ----------------------------------------------------------
  // fromJson — parses Gemini's response into a VibeBundle
  // We pass the userPrompt separately since Gemini doesn't
  // return it — it was the input
  // ----------------------------------------------------------
  factory VibeBundle.fromGeminiJson(
      Map<String, dynamic> json,
      String userPrompt,
      ) {
    return VibeBundle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userPrompt: userPrompt,
      createdAt: DateTime.now(),
      visualPrompt: json['visual_prompt'] ?? '',
      moodTag: json['mood_tag'] ?? 'chill',
      posterHeadline: json['poster_headline'] ?? '',
      posterSubheadline: json['poster_subheadline'] ?? '',
      memeTopText: json['meme_top_text'] ?? '',
      memeBottomText: json['meme_bottom_text'] ?? '',
      colorPalette: json['color_palette'] ?? 'purple, dark, teal',
      fontMood: json['font_mood'] ?? 'bold',
    );
  }

  // ----------------------------------------------------------
  // fromFirestore — rebuilds a saved VibeBundle from Firestore
  // ----------------------------------------------------------
  factory VibeBundle.fromFirestore(Map<String, dynamic> data, String docId) {
    return VibeBundle(
      id: docId,
      userPrompt: data['user_prompt'] ?? '',
      createdAt: (data['created_at'] as dynamic).toDate(),
      visualPrompt: data['visual_prompt'] ?? '',
      moodTag: data['mood_tag'] ?? 'chill',
      posterHeadline: data['poster_headline'] ?? '',
      posterSubheadline: data['poster_subheadline'] ?? '',
      memeTopText: data['meme_top_text'] ?? '',
      memeBottomText: data['meme_bottom_text'] ?? '',
      colorPalette: data['color_palette'] ?? '',
      fontMood: data['font_mood'] ?? 'bold',
      imageUrl: data['image_url'],
      audioUrl: data['audio_url'],
      isSaved: data['is_saved'] ?? false,
    );
  }

  // ----------------------------------------------------------
  // toFirestore — converts to Map for saving to Firestore
  // ----------------------------------------------------------
  Map<String, dynamic> toFirestore() {
    return {
      'user_prompt': userPrompt,
      'created_at': createdAt,
      'visual_prompt': visualPrompt,
      'mood_tag': moodTag,
      'poster_headline': posterHeadline,
      'poster_subheadline': posterSubheadline,
      'meme_top_text': memeTopText,
      'meme_bottom_text': memeBottomText,
      'color_palette': colorPalette,
      'font_mood': fontMood,
      'image_url': imageUrl,
      'audio_url': audioUrl,
      'is_saved': isSaved,
    };
  }

  // ----------------------------------------------------------
  // copyWith — creates updated version without mutation
  // Used by provider to attach image/audio URLs after generation
  // ----------------------------------------------------------
  VibeBundle copyWith({
    String? imageUrl,
    String? audioUrl,
    bool? isSaved,
  }) {
    return VibeBundle(
      id: id,
      userPrompt: userPrompt,
      createdAt: createdAt,
      visualPrompt: visualPrompt,
      moodTag: moodTag,
      posterHeadline: posterHeadline,
      posterSubheadline: posterSubheadline,
      memeTopText: memeTopText,
      memeBottomText: memeBottomText,
      colorPalette: colorPalette,
      fontMood: fontMood,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
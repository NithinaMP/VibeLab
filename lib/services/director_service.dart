// ============================================================
// VibeLab — director_service.dart (Fixed)
// Single request per generate click.
// One retry ONLY on 503 overload — not on every failure.
// Switches to gemini-2.0-flash for better free tier limits.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/vibe_bundle.dart';

class DirectorService {
//   static const String _systemPrompt = '''
// You are VibeLab's Creative Director — a world-class art director and music producer combined into one AI.
//
// Your job: Take a user's mood, vibe, or theme description and generate a perfectly synchronized creative blueprint. Every element you create must feel like it belongs to the same creative universe.
//
// You MUST respond with ONLY a valid JSON object. No explanation. No markdown. No code blocks. Just raw JSON.
//
// The JSON must follow this exact structure:
// {
//   "visual_prompt": "A highly detailed image generation prompt. Include: art style, color palette, lighting, mood, specific visual elements, composition. Make it rich and specific. Min 30 words.",
//   "mood_tag": "One of exactly these values: chill, hype, dark, retro, nature, cyberpunk, romantic, corporate",
//   "poster_headline": "A punchy 1-4 word headline in ALL CAPS that captures the essence",
//   "poster_subheadline": "A cinematic one-liner that deepens the mood. 8-12 words.",
//   "meme_top_text": "Relatable meme setup text IN ALL CAPS. Keep it short, punchy, culturally relevant.",
//   "meme_bottom_text": "The punchline IN ALL CAPS. Must be funny or deeply relatable.",
//   "color_palette": "3 specific colors that define this vibe, comma separated (e.g. 'deep purple, electric teal, cosmic black')",
//   "font_mood": "One of: bold, elegant, glitchy, handwritten, minimal"
// }
//
// Rules:
// - The visual_prompt must be so specific that an image generator produces a stunning, cohesive result
// - The mood_tag determines the background music — choose the one that fits best
// - The poster and meme texts must feel like they came from the same creative mind
// - Everything must feel synchronized and intentional — like a professional brand kit
// - Never use generic phrases. Be specific, evocative, and unexpected.
// ''';
  static const String _systemPrompt = '''
You are a creative director. Given a mood/vibe, return ONLY a JSON object with these exact fields:
{
  "visual_prompt": "detailed image generation prompt, art style, colors, lighting, 20+ words",
  "mood_tag": "one of: chill, hype, dark, retro, nature, cyberpunk, romantic, corporate",
  "poster_headline": "1-4 WORDS ALL CAPS",
  "poster_subheadline": "one cinematic sentence",
  "meme_top_text": "SHORT ALL CAPS SETUP",
  "meme_bottom_text": "ALL CAPS PUNCHLINE",
  "color_palette": "3 colors comma separated",
  "font_mood": "one of: bold, elegant, glitchy, handwritten, minimal"
}
No markdown. No explanation. Raw JSON only.
''';

  Future<VibeBundle> generateVibeBlueprint(String userPrompt) async {
    // Debug log — one print per click confirms no duplicate requests
    print('GEMINI REQUEST STARTED — prompt: "$userPrompt"');

    final url = Uri.parse(
      '${VibeLabConstants.geminiBaseUrl}/${VibeLabConstants.geminiModel}:generateContent'
          '?key=${VibeLabConstants.geminiApiKey}',
    );

    final requestBody = {
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt}
        ]
      },
      'contents': [
        {
          'parts': [
            {
              'text':
              'Create a complete creative blueprint for this vibe: "$userPrompt"'
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.9,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 512,
      },
    };

    try {
      // SINGLE request — no retry loop
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('GEMINI STATUS: ${response.statusCode}');

      // ONLY retry on 503 overload — one extra attempt, nothing more
      if (response.statusCode == 503) {
        print('GEMINI 503 — waiting 3s then retrying once...');
        await Future.delayed(const Duration(seconds: 3));

        final retryResponse = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        print('GEMINI RETRY STATUS: ${retryResponse.statusCode}');

        if (retryResponse.statusCode != 200) {
          throw Exception(
            'STATUS: ${retryResponse.statusCode}\nBODY: ${retryResponse.body}',
          );
        }

        return _parseResponse(retryResponse.body, userPrompt);
      }

      if (response.statusCode != 200) {
        throw Exception(
          'STATUS: ${response.statusCode}\nBODY: ${response.body}',
        );
      }

      return _parseResponse(response.body, userPrompt);
    } catch (e) {
      throw Exception('Creative Director failed: $e');
    }
  }

  // ----------------------------------------------------------
  // Parse Gemini response into VibeBundle
  // ----------------------------------------------------------
  VibeBundle _parseResponse(String responseBody, String userPrompt) {
    final responseData = jsonDecode(responseBody);
    final String rawText =
    responseData['candidates'][0]['content']['parts'][0]['text'];
    final String cleanedJson = _extractJson(rawText);
    final Map<String, dynamic> blueprintJson = jsonDecode(cleanedJson);
    return VibeBundle.fromGeminiJson(blueprintJson, userPrompt);
  }

  // ----------------------------------------------------------
  // Strip markdown code blocks if Gemini wraps JSON in them
  // ----------------------------------------------------------
  String _extractJson(String raw) {
    String cleaned = raw.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }
}
// ============================================================
// VibeLab — director_service.dart
// The Creative Director. This is the brain of VibeLab.
// Sends the user's vibe to Gemini Flash-Lite and gets back
// a structured JSON blueprint for every other service to use.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/vibe_bundle.dart';

class DirectorService {
  // ----------------------------------------------------------
  // THE MASTER PROMPT
  // This is the most important string in the entire app.
  // It tells Gemini exactly what role to play and exactly
  // what JSON structure to return. Never change the field
  // names here without updating VibeBundle.fromGeminiJson()
  // ----------------------------------------------------------
  static const String _systemPrompt = '''
You are VibeLab's Creative Director — a world-class art director and music producer combined into one AI.

Your job: Take a user's mood, vibe, or theme description and generate a perfectly synchronized creative blueprint. Every element you create must feel like it belongs to the same creative universe.

You MUST respond with ONLY a valid JSON object. No explanation. No markdown. No code blocks. Just raw JSON.

The JSON must follow this exact structure:
{
  "visual_prompt": "A highly detailed image generation prompt. Include: art style, color palette, lighting, mood, specific visual elements, composition. Make it rich and specific. Min 30 words.",
  "mood_tag": "One of exactly these values: chill, hype, dark, retro, nature, cyberpunk, romantic, corporate",
  "poster_headline": "A punchy 1-4 word headline in ALL CAPS that captures the essence",
  "poster_subheadline": "A cinematic one-liner that deepens the mood. 8-12 words.",
  "meme_top_text": "Relatable meme setup text IN ALL CAPS. Keep it short, punchy, culturally relevant.",
  "meme_bottom_text": "The punchline IN ALL CAPS. Must be funny or deeply relatable.",
  "color_palette": "3 specific colors that define this vibe, comma separated (e.g. 'deep purple, electric teal, cosmic black')",
  "font_mood": "One of: bold, elegant, glitchy, handwritten, minimal"
}

Rules:
- The visual_prompt must be so specific that an image generator produces a stunning, cohesive result
- The mood_tag determines the background music — choose the one that fits best
- The poster and meme texts must feel like they came from the same creative mind
- Everything must feel synchronized and intentional — like a professional brand kit
- Never use generic phrases. Be specific, evocative, and unexpected.
''';

  // ----------------------------------------------------------
  // generateVibeBlueprint
  // Main method called by VibeProvider when user hits Generate
  // Returns a VibeBundle with all Gemini fields populated
  // Throws exceptions that VibeProvider catches and displays
  // ----------------------------------------------------------
  // Future<VibeBundle> generateVibeBlueprint(String userPrompt) async {
  //   final url = Uri.parse(
  //     '${VibeLabConstants.geminiBaseUrl}/${VibeLabConstants.geminiModel}:generateContent'
  //   '?key=${VibeLabConstants.geminiApiKey}',
  //   );
  //
  //   final requestBody = {
  //     'system_instruction': {
  //       'parts': [
  //         {'text': _systemPrompt}
  //       ]
  //     },
  //     'contents': [
  //       {
  //         'parts': [
  //           {
  //             'text': 'Create a complete creative blueprint for this vibe: "$userPrompt"'
  //           }
  //         ]
  //       }
  //     ],
  //     'generationConfig': {
  //       'temperature': 0.9,      // High creativity
  //       'topK': 40,
  //       'topP': 0.95,
  //       'maxOutputTokens': 1024, // JSON response is always small
  //     },
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(requestBody),
  //     );
  //
  //     if (response.statusCode != 200) {
  //       print('STATUS: ${response.statusCode}');
  //       print('BODY: ${response.body}');
  //       throw Exception(
  //         'Gemini API error ${response.statusCode}: ${response.body}',
  //       );
  //     }
  //
  //     final responseData = jsonDecode(response.body);
  //
  //     // Extract the text content from Gemini's response structure
  //     final String rawText = responseData['candidates'][0]['content']['parts'][0]['text'];
  //
  //     // Clean the response — Gemini sometimes wraps JSON in markdown
  //     // even when told not to. This handles that case safely.
  //     final String cleanedJson = _extractJson(rawText);
  //
  //     // Parse into a Map
  //     final Map<String, dynamic> blueprintJson = jsonDecode(cleanedJson);
  //
  //     // Convert to VibeBundle and return
  //     return VibeBundle.fromGeminiJson(blueprintJson, userPrompt);
  //   } catch (e) {
  //     throw Exception('Creative Director failed: $e');
  //   }
  // }



  Future<VibeBundle> generateVibeBlueprint(String userPrompt) async {
    // Retry up to 3 times with delay — handles 503 overload spikes
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
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
                  'text': 'Create a complete creative blueprint for this vibe: "$userPrompt"'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.9,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        };

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 503) {
          if (attempt < 3) {
            // Wait longer each retry — 2s, then 4s
            await Future.delayed(Duration(seconds: attempt * 2));
            continue; // try again
          }
          throw Exception('503: Gemini is overloaded. Please try again in a moment.');
        }

        if (response.statusCode != 200) {
          throw Exception('STATUS: ${response.statusCode}\nBODY: ${response.body}');
        }

        final responseData = jsonDecode(response.body);
        final String rawText =
        responseData['candidates'][0]['content']['parts'][0]['text'];
        final String cleanedJson = _extractJson(rawText);
        final Map<String, dynamic> blueprintJson = jsonDecode(cleanedJson);
        return VibeBundle.fromGeminiJson(blueprintJson, userPrompt);

      } catch (e) {
        if (attempt == 3) {
          throw Exception('Creative Director failed after 3 attempts: $e');
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    throw Exception('Creative Director failed: max retries exceeded');
  }
  // ----------------------------------------------------------
  // _extractJson
  // Safety method: strips markdown code blocks if Gemini
  // wraps the JSON in ```json ... ``` despite instructions
  // ----------------------------------------------------------
  String _extractJson(String raw) {
    // Remove markdown code blocks if present
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
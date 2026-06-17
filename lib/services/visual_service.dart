// ============================================================
// VibeLab — visual_service.dart
// Handles all image generation via Pollinations.ai
// Pollinations returns images via a direct URL — no upload
// needed. We just build the URL and Flutter loads it.
// ============================================================

import '../core/constants.dart';

class VisualService {
  // ----------------------------------------------------------
  // generateImageUrl
  // Pollinations.ai works by constructing a GET URL.
  // The image is returned directly at that URL.
  // Flutter's Image.network() loads it like any web image.
  //
  // We add a seed based on timestamp so each generation is
  // unique even for the same prompt.
  // ----------------------------------------------------------
  String generateImageUrl(String visualPrompt) {
    // URL-encode the prompt — spaces and special chars must be encoded
    final encodedPrompt = Uri.encodeComponent(visualPrompt);

    // Unique seed for this generation
    final seed = DateTime.now().millisecondsSinceEpoch % 999999;

    // Build the Pollinations URL with all parameters
    final url = '${VibeLabConstants.pollinationsBaseUrl}/$encodedPrompt'
        '?width=${VibeLabConstants.imageWidth}'
        '&height=${VibeLabConstants.imageHeight}'
        '&seed=$seed'
        '&model=flux'           // Flux model — best free quality
        '&enhance=true'         // Pollinations auto-enhances prompt
        '&nologo=true'          // Remove Pollinations watermark
        '&referrer=${VibeLabConstants.pollinationsReferrer}';

    return url;
  }

  // ----------------------------------------------------------
  // generatePosterImageUrl
  // Slightly different config for poster mode —
  // portrait ratio is better for promotional content
  // ----------------------------------------------------------
  String generatePosterImageUrl(String visualPrompt) {
    final encodedPrompt = Uri.encodeComponent(
      '$visualPrompt, vertical poster composition, dramatic lighting, '
          'professional graphic design aesthetic',
    );

    final seed = DateTime.now().millisecondsSinceEpoch % 999999;

    return '${VibeLabConstants.pollinationsBaseUrl}/$encodedPrompt'
        '?width=768'
        '&height=1024'
        '&seed=$seed'
        '&model=flux'
        '&enhance=true'
        '&nologo=true'
        '&referrer=${VibeLabConstants.pollinationsReferrer}';
  }

  // ----------------------------------------------------------
  // generateMemeImageUrl
  // Square format works best for memes
  // ----------------------------------------------------------
  String generateMemeImageUrl(String visualPrompt) {
    final encodedPrompt = Uri.encodeComponent(
      '$visualPrompt, dramatic scene, cinematic, high contrast, '
          'suitable for meme template',
    );

    final seed = DateTime.now().millisecondsSinceEpoch % 999999;

    return '${VibeLabConstants.pollinationsBaseUrl}/$encodedPrompt'
        '?width=1024'
        '&height=1024'
        '&seed=$seed'
        '&model=flux'
        '&enhance=true'
        '&nologo=true'
        '&referrer=${VibeLabConstants.pollinationsReferrer}';
  }
}
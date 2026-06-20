// ============================================================
// VibeLab — vibe_provider.dart
// The single source of truth for the entire app's state.
// Every screen reads from here. Every action goes through here.
// This is the spine that connects all services together.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vibe_bundle.dart';
import '../services/director_service.dart';
import '../services/visual_service.dart';
import '../services/audio_service.dart';
import '../core/constants.dart';

// ----------------------------------------------------------
// App-wide generation states
// UI reacts to these — each state maps to a different screen
// ----------------------------------------------------------
enum VibeState {
  idle,        // Home screen — waiting for user input
  loading,     // Generation in progress — show loading overlay
  success,     // Generation complete — show studio screen
  error,       // Something failed — show error message
}

class VibeProvider extends ChangeNotifier {
  // ----------------------------------------------------------
  // SERVICES
  // ----------------------------------------------------------
  final DirectorService _director = DirectorService();
  final VisualService _visual = VisualService();
  final AudioService _audio = AudioService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ----------------------------------------------------------
  // STATE
  // ----------------------------------------------------------
  VibeState _state = VibeState.idle;
  VibeBundle? _currentVibe;
  List<VibeBundle> _gallery = [];
  String _errorMessage = '';
  String _loadingMessage = VibeLabConstants.loadingMessages[0];
  bool _isPosterMode = true;  // true = poster, false = meme
  bool _isGalleryLoading = false;

  // ----------------------------------------------------------
  // GETTERS — screens read these
  // ----------------------------------------------------------
  VibeState get state => _state;
  VibeBundle? get currentVibe => _currentVibe;
  List<VibeBundle> get gallery => _gallery;
  String get errorMessage => _errorMessage;
  String get loadingMessage => _loadingMessage;
  bool get isPosterMode => _isPosterMode;
  bool get isGalleryLoading => _isGalleryLoading;

  // ----------------------------------------------------------
  // generateVibe
  // THE MAIN METHOD. Called when user taps "Generate".
  // Orchestrates the entire 3-step pipeline:
  // 1. Gemini creates the blueprint
  // 2. Pollinations generates the image URL
  // 3. Firebase Storage provides the audio URL
  // ----------------------------------------------------------
  Future<void> generateVibe(String userPrompt) async {
    if (userPrompt.trim().isEmpty) return;

    // Step 0: Set loading state and start cycling messages
    _setState(VibeState.loading);
    _startLoadingMessages();

    try {
      // Step 1: Gemini Creative Director creates the blueprint
      // This is the most important call — everything depends on it
      final vibeBundle = await _director.generateVibeBlueprint(userPrompt);

      // Step 2: Generate the image URL from Pollinations
      // We build the URL — no async needed, image loads lazily
      final imageUrl = _isPosterMode
          ? _visual.generatePosterImageUrl(vibeBundle.visualPrompt)
          : _visual.generateMemeImageUrl(vibeBundle.visualPrompt);

      // Step 3: Get audio stem URL from Firebase Storage
      final audioUrl = await _audio.getAudioUrlForMood(vibeBundle.moodTag);

      // Attach URLs to the bundle using copyWith (immutable update)
      _currentVibe = vibeBundle.copyWith(
        imageUrl: imageUrl,
        audioUrl: audioUrl,
      );

      // Success — UI will navigate to studio screen
      _setState(VibeState.success);
    } catch (e) {
      print('VIBELAB ERROR: $e');

      _errorMessage = _friendlyError(e.toString());
      _setState(VibeState.error);
    }
  }

  // ----------------------------------------------------------
  // saveToGallery
  // Saves the current VibeBundle to Firestore
  // Called when user taps the save button in studio screen
  // ----------------------------------------------------------
  Future<void> saveToGallery() async {
    if (_currentVibe == null) return;

    try {
      // Save to Firestore
      await _firestore
          .collection(VibeLabConstants.vibesCollection)
          .doc(_currentVibe!.id)
          .set(_currentVibe!.toFirestore());

      // Mark as saved in current state
      _currentVibe = _currentVibe!.copyWith(isSaved: true);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Could not save to gallery: $e';
      notifyListeners();
    }
  }

  // ----------------------------------------------------------
  // loadGallery
  // Fetches all saved vibes from Firestore for gallery screen
  // ----------------------------------------------------------
  Future<void> loadGallery() async {
    _isGalleryLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(VibeLabConstants.vibesCollection)
          .orderBy('created_at', descending: true)
          .limit(50) // Limit to 50 to stay within Spark free reads
          .get();

      _gallery = snapshot.docs
          .map((doc) => VibeBundle.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _errorMessage = 'Could not load gallery: $e';
    } finally {
      _isGalleryLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------
  // toggleMode
  // Switches between poster and meme mode in studio screen
  // Regenerates the image URL for the new mode
  // ----------------------------------------------------------
  void toggleMode() {
    if (_currentVibe == null) return;
    _isPosterMode = !_isPosterMode;

    // Regenerate image URL for the new mode
    final newImageUrl = _isPosterMode
        ? _visual.generatePosterImageUrl(_currentVibe!.visualPrompt)
        : _visual.generateMemeImageUrl(_currentVibe!.visualPrompt);

    _currentVibe = _currentVibe!.copyWith(imageUrl: newImageUrl);
    notifyListeners();
  }
  void updateCurrentVibe(VibeBundle updatedVibe) {
    _currentVibe = updatedVibe;
    notifyListeners();
  }

  // ----------------------------------------------------------
  // resetToHome
  // Called when user wants to generate a new vibe
  // ----------------------------------------------------------
  void resetToHome() {
    _currentVibe = null;
    _errorMessage = '';
    _setState(VibeState.idle);
  }

  // ----------------------------------------------------------
  // PRIVATE HELPERS
  // ----------------------------------------------------------

  void _setState(VibeState newState) {
    _state = newState;
    notifyListeners();
  }

  // Cycles through loading messages with a delay
  // so the loading screen feels alive and on-brand
  Future<void> _startLoadingMessages() async {
    final messages = VibeLabConstants.loadingMessages;
    for (int i = 0; i < messages.length; i++) {
      if (_state != VibeState.loading) break; // Stop if loading ended
      _loadingMessage = messages[i];
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1200));
    }
  }

  // Converts technical errors into friendly user messages
  // String _friendlyError(String technical) {
  //   if (technical.contains('401') || technical.contains('API key')) {
  //     return 'API key issue. Check your Gemini key in constants.dart';
  //   }
  //   if (technical.contains('429') || technical.contains('quota')) {
  //     return 'Daily limit reached. Gemini Flash-Lite allows 1000 free requests/day.';
  //   }
  //   if (technical.contains('Audio stem not found')) {
  //     return 'Audio stems not uploaded yet. Check Firebase Storage setup.';
  //   }
  //   if (technical.contains('network') || technical.contains('SocketException')) {
  //     return 'No internet connection. Check your network and try again.';
  //   }
  //   return 'Something went wrong. Please try again.';
  // }

  String _friendlyError(String technical) {
    if (technical.contains('503') || technical.contains('overloaded')) {
      return 'Gemini is busy right now 🌊 Please try again in a few seconds.';
    }
    if (technical.contains('401') || technical.contains('API key')) {
      return 'API key issue. Check your Gemini key in secrets.dart';
    }
    if (technical.contains('429') || technical.contains('quota')) {
      return 'Daily limit reached. Gemini 2.5 Flash allows 250 free requests/day.';
    }
    if (technical.contains('Audio stem not found')) {
      return 'Audio stems not uploaded yet. Check Firebase Storage setup.';
    }
    if (technical.contains('network') || technical.contains('SocketException')) {
      return 'No internet connection. Check your network and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
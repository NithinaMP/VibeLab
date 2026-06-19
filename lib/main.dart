// ============================================================
// VibeLab — main.dart (Updated with AuthProvider)
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/vibe_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VibeLab());
}

class VibeLab extends StatelessWidget {
  const VibeLab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VibeProvider()),
      ],
      child: MaterialApp(
        title: 'VibeLab',
        debugShowCheckedModeBanner: false,
        theme: VibeLabTheme.darkTheme(),
        // App always starts at SplashScreen
        // SplashScreen routes to Login or Home based on auth state
        home: const SplashScreen(),
      ),
    );
  }
}
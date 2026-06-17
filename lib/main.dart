// ============================================================
// VibeLab — main.dart
// Entry point. Initializes Firebase, sets up Provider,
// and launches the app with the Aurora theme.
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/vibe_provider.dart';
import 'screens/home_screen.dart';
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
        ChangeNotifierProvider(create: (_) => VibeProvider()),
      ],
      child: MaterialApp(
        title: 'VibeLab',
        debugShowCheckedModeBanner: false,
        theme: VibeLabTheme.darkTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
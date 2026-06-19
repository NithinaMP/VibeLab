// ============================================================
// VibeLab — register_screen.dart
// Create account with name, email, password.
// Brutalist Dark Aurora aesthetic.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/aurora_background.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _validationError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) {
      return 'Please enter your name.';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'Please enter your email.';
    }
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (_passwordController.text != _confirmController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> _register(AuthProvider auth) async {
    final error = _validate();
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }

    setState(() => _validationError = null);

    await auth.registerWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    if (auth.isAuthenticated && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLoading = auth.state == AuthState.loading;

        return AuroraBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: VibeLabTheme.borderNormal,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '< BACK',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 8,
                                color: VibeLabTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Header
                        Text(
                          'CREATE\nACCOUNT.',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 22,
                            color: VibeLabTheme.textPrimary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          width: 40,
                          height: 3,
                          color: VibeLabTheme.vibeLime,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Join VibeLab. Start creating.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: VibeLabTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Auth error
                        if (auth.state == AuthState.error) ...[
                          _ErrorBanner(
                            message: auth.errorMessage,
                            onDismiss: auth.clearError,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Validation error
                        if (_validationError != null) ...[
                          _ErrorBanner(
                            message: _validationError!,
                            onDismiss: () =>
                                setState(() => _validationError = null),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Name field
                        _BrutalistField(
                          controller: _nameController,
                          label: 'YOUR NAME',
                          hint: 'Vibe Creator',
                        ),

                        const SizedBox(height: 12),

                        // Email field
                        _BrutalistField(
                          controller: _emailController,
                          label: 'EMAIL',
                          hint: 'your@email.com',
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 12),

                        // Password field
                        _BrutalistField(
                          controller: _passwordController,
                          label: 'PASSWORD',
                          hint: 'min 6 characters',
                          obscureText: _obscurePassword,
                          onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Confirm password
                        _BrutalistField(
                          controller: _confirmController,
                          label: 'CONFIRM PASSWORD',
                          hint: 'repeat password',
                          obscureText: _obscureConfirm,
                          onToggleObscure: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Create account button
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: isLoading ? null : () => _register(auth),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isLoading
                                    ? VibeLabTheme.vibeLime.withOpacity(0.5)
                                    : VibeLabTheme.vibeLime,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: VibeLabTheme.vibeLime,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: VibeLabTheme.textDark,
                                  ),
                                )
                                    : Text(
                                  'CREATE ACCOUNT',
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 10,
                                    color: VibeLabTheme.textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrutalistField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final VoidCallback? onToggleObscure;

  const _BrutalistField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 8,
            color: VibeLabTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            color: VibeLabTheme.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: onToggleObscure != null
                ? GestureDetector(
              onTap: onToggleObscure,
              child: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: VibeLabTheme.textHint,
                size: 18,
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.red.shade300,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: Colors.red, size: 16),
          ),
        ],
      ),
    );
  }
}
// ============================================================
// VibeLab — profile_screen.dart
// Full user profile: name, photo, stats, edit, delete account.
// Brutalist Dark Aurora aesthetic.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vibe_provider.dart';
import '../../widgets/aurora_background.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.displayName);
    // Refresh stats when page opens
    auth.loadUserStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName(AuthProvider auth) async {
    if (_nameController.text.trim().isEmpty) return;
    await auth.updateDisplayName(_nameController.text.trim());
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'NAME UPDATED',
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: VibeLabTheme.textDark,
            ),
          ),
          backgroundColor: VibeLabTheme.vibeLime,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }
  }

  Future<void> _signOut(AuthProvider auth) async {
    // Confirm dialog
    final confirmed = await _showConfirmDialog(
      title: 'SIGN OUT',
      message: 'Are you sure you want to sign out?',
      confirmLabel: 'SIGN OUT',
      isDangerous: false,
    );

    if (confirmed && mounted) {
      context.read<VibeProvider>().resetToHome();
      await auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
              (route) => false,
        );
      }
    }
  }

  Future<void> _deleteAccount(AuthProvider auth) async {
    final confirmed = await _showConfirmDialog(
      title: 'DELETE ACCOUNT',
      message:
      'This will permanently delete your account and all saved vibes. This cannot be undone.',
      confirmLabel: 'DELETE',
      isDangerous: true,
    );

    if (confirmed && mounted) {
      await auth.deleteAccount();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
              (route) => false,
        );
      }
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required bool isDangerous,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: VibeLabTheme.cosmicInkLighter,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(
              color: VibeLabTheme.borderNormal,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: isDangerous
                        ? Colors.red.shade400
                        : VibeLabTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: VibeLabTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: VibeLabTheme.borderNormal,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 8,
                                color: VibeLabTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isDangerous
                                ? Colors.red.withOpacity(0.2)
                                : VibeLabTheme.vibeLime,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDangerous
                                  ? Colors.red.shade400
                                  : VibeLabTheme.vibeLime,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              confirmLabel,
                              style: GoogleFonts.pressStart2p(
                                fontSize: 8,
                                color: isDangerous
                                    ? Colors.red.shade400
                                    : VibeLabTheme.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return AuroraBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  _ProfileTopBar(),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar + Name section
                            _AvatarSection(
                              auth: auth,
                              isEditing: _isEditing,
                              nameController: _nameController,
                              onEditTap: () =>
                                  setState(() => _isEditing = true),
                              onSaveTap: () => _saveName(auth),
                              onCancelTap: () {
                                _nameController.text = auth.displayName;
                                setState(() => _isEditing = false);
                              },
                            ),

                            const SizedBox(height: 32),

                            // Stats section
                            _StatsSection(auth: auth),

                            const SizedBox(height: 32),

                            // Account info section
                            _AccountInfoSection(auth: auth),

                            const SizedBox(height: 32),

                            // Actions section
                            _ActionsSection(
                              onSignOut: () => _signOut(auth),
                              onDeleteAccount: () => _deleteAccount(auth),
                              isLoading: auth.state == AuthState.loading,
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------
// Profile top bar
// ----------------------------------------------------------
class _ProfileTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VibeLabTheme.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
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
          const SizedBox(width: 16),
          Text(
            'PROFILE',
            style: GoogleFonts.pressStart2p(
              fontSize: 14,
              color: VibeLabTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Avatar + name section
// ----------------------------------------------------------
class _AvatarSection extends StatelessWidget {
  final AuthProvider auth;
  final bool isEditing;
  final TextEditingController nameController;
  final VoidCallback onEditTap;
  final VoidCallback onSaveTap;
  final VoidCallback onCancelTap;

  const _AvatarSection({
    required this.auth,
    required this.isEditing,
    required this.nameController,
    required this.onEditTap,
    required this.onSaveTap,
    required this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: VibeLabTheme.vibeLime,
              width: 2,
            ),
            color: VibeLabTheme.cosmicInkLighter,
          ),
          child: auth.photoUrl.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.network(
              auth.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _DefaultAvatar(
                name: auth.displayName,
              ),
            ),
          )
              : _DefaultAvatar(name: auth.displayName),
        ),

        const SizedBox(width: 20),

        // Name + edit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isEditing) ...[
                TextField(
                  controller: nameController,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: VibeLabTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onSaveTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: VibeLabTheme.vibeLime,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SAVE',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7,
                            color: VibeLabTheme.textDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onCancelTap,
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7,
                          color: VibeLabTheme.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  auth.displayName,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14,
                    color: VibeLabTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: VibeLabTheme.borderNormal,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'EDIT NAME',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: VibeLabTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// Default avatar — shows first letter of name
// ----------------------------------------------------------
class _DefaultAvatar extends StatelessWidget {
  final String name;
  const _DefaultAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'V',
        style: GoogleFonts.pressStart2p(
          fontSize: 24,
          color: VibeLabTheme.vibeLime,
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Stats section
// ----------------------------------------------------------
class _StatsSection extends StatelessWidget {
  final AuthProvider auth;
  const _StatsSection({required this.auth});

  @override
  Widget build(BuildContext context) {
    final totalVibes = auth.userStats['total_vibes'] ?? 0;
    final joinedAt = auth.userStats['joined_at'];

    String joinedText = 'RECENTLY';
    if (joinedAt != null) {
      final date = (joinedAt as dynamic).toDate() as DateTime;
      joinedText =
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATS',
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: VibeLabTheme.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: totalVibes.toString(),
                label: 'VIBES\nCREATED',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                value: joinedText,
                label: 'MEMBER\nSINCE',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                value: totalVibes > 10
                    ? 'PRO'
                    : totalVibes > 0
                    ? 'ACTIVE'
                    : 'NEW',
                label: 'VIBE\nSTATUS',
                valueColor: totalVibes > 10
                    ? VibeLabTheme.vibeLime
                    : VibeLabTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VibeLabTheme.cosmicInkLighter,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: VibeLabTheme.borderSubtle, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.pressStart2p(
              fontSize: 14,
              color: valueColor ?? VibeLabTheme.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: VibeLabTheme.textHint,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Account info section
// ----------------------------------------------------------
class _AccountInfoSection extends StatelessWidget {
  final AuthProvider auth;
  const _AccountInfoSection({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT',
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: VibeLabTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VibeLabTheme.cosmicInkLighter,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: VibeLabTheme.borderSubtle, width: 2),
          ),
          child: Column(
            children: [
              _InfoRow(label: 'EMAIL', value: auth.email),
              const SizedBox(height: 12),
              _InfoRow(
                label: 'SIGN IN',
                value: auth.user?.providerData.isNotEmpty == true
                    ? auth.user!.providerData[0].providerId
                    .replaceAll('.com', '')
                    .toUpperCase()
                    : 'EMAIL',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 7,
              color: VibeLabTheme.textHint,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: VibeLabTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// Actions section
// ----------------------------------------------------------
class _ActionsSection extends StatelessWidget {
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;
  final bool isLoading;

  const _ActionsSection({
    required this.onSignOut,
    required this.onDeleteAccount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIONS',
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: VibeLabTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Sign out
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: isLoading ? null : onSignOut,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: VibeLabTheme.borderNormal,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  'SIGN OUT',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: VibeLabTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Delete account — dangerous
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: isLoading ? null : onDeleteAccount,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.red.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  'DELETE ACCOUNT',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
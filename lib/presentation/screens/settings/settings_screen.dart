import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../main.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isEditingName = false;
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _changeAvatar() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (!mounted) return;
      if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Photo library permission permanently denied. Enable it in Settings.'),
            action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Photo library permission is required.')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 85,
    );
    if (picked == null) return;

    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    try {
      final storageService = ref.read(storageServiceProvider);
      final downloadUrl = await storageService.uploadAvatar(
        userId: userId,
        imageFile: File(picked.path),
      );
      await ref
          .read(authNotifierProvider.notifier)
          .updateProfile(photoUrl: downloadUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo: $e')),
        );
      }
    }
  }

  Future<void> _saveName() async {
    if (_nameCtrl.text.trim().length < 2) return;
    await ref.read(authNotifierProvider.notifier).updateProfile(
          displayName: _nameCtrl.text.trim(),
        );
    if (mounted) setState(() => _isEditingName = false);
  }

  Future<void> _sendPasswordReset(String email) async {
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent to $email')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset email: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  void _setTheme(String mode) {
    final box = Hive.box(AppConstants.settingsBox);
    box.put(AppConstants.themeKey, mode);
    final themeMode = switch (mode) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    ref.read(themeModeProvider.notifier).state = themeMode;
  }

  Future<void> _setNotifications(bool enabled) async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(AppConstants.notificationsKey, enabled);
    final fcm = ref.read(fcmServiceProvider);
    if (enabled) {
      await fcm.subscribeToTopic(AppConstants.fcmTopicAll);
    } else {
      await fcm.unsubscribeFromTopic(AppConstants.fcmTopicAll);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserModelProvider);
    final authState = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    final currentThemeKey = themeMode == ThemeMode.dark
        ? 'dark'
        : themeMode == ThemeMode.light
            ? 'light'
            : 'system';

    final notificationsEnabled = Hive.box(AppConstants.settingsBox)
        .get(AppConstants.notificationsKey, defaultValue: true) as bool;

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: 'Saving...',
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: userAsync.when(
          loading: () => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Sign Out',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red)),
                ),
              ],
            ),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (user) {
            if (user == null) {
              // Firestore document missing but Firebase Auth may still have a session.
              // Show a recovery screen so the user can sign out.
              final firebaseUser = ref.read(authStateProvider).value;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_circle_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        firebaseUser != null
                            ? 'Setting up your account…'
                            : 'Not logged in',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (firebaseUser != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          firebaseUser.email ?? '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                        ),
                        const SizedBox(height: 8),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                      ] else
                        const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Sign Out',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView(
              children: [
                // ── Profile Header ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _changeAvatar,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor:
                                  AppTheme.primaryColor.withOpacity(0.1),
                              backgroundImage: user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? Text(
                                      user.displayName.isNotEmpty
                                          ? user.displayName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryColor,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_isEditingName)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameCtrl,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  labelText: 'Display Name',
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _saveName(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.check,
                                  color: Colors.green),
                              onPressed: _saveName,
                              tooltip: 'Save',
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => _isEditingName = false),
                              tooltip: 'Cancel',
                            ),
                          ],
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            _nameCtrl.text = user.displayName;
                            setState(() => _isEditingName = true);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(user.displayName,
                                  style: theme.textTheme.titleLarge),
                              const SizedBox(width: 6),
                              Icon(Icons.edit_outlined,
                                  size: 16,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Account ───────────────────────────────────────────
                _SectionHeader(label: 'Account'),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Role'),
                  subtitle: Text(user.role),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => _showRolePicker(context, user.role),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset_outlined),
                  title: const Text('Change Password'),
                  subtitle: const Text('Send a reset link to your email'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => _sendPasswordReset(user.email),
                ),

                // ── Appearance ────────────────────────────────────────
                _SectionHeader(label: 'Appearance'),
                _ThemeOption(
                  label: 'System Default',
                  icon: Icons.brightness_auto_outlined,
                  selected: currentThemeKey == 'system',
                  onTap: () => _setTheme('system'),
                ),
                _ThemeOption(
                  label: 'Light Mode',
                  icon: Icons.wb_sunny_outlined,
                  selected: currentThemeKey == 'light',
                  onTap: () => _setTheme('light'),
                ),
                _ThemeOption(
                  label: 'Dark Mode',
                  icon: Icons.nightlight_outlined,
                  selected: currentThemeKey == 'dark',
                  onTap: () => _setTheme('dark'),
                ),

                // ── Notifications ─────────────────────────────────────
                _SectionHeader(label: 'Notifications'),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Analysis Results'),
                  subtitle: const Text(
                      'Get notified when AI analysis is complete'),
                  value: notificationsEnabled,
                  onChanged: _setNotifications,
                  activeThumbColor: AppTheme.primaryColor,
                ),

                // ── About ─────────────────────────────────────────────
                _SectionHeader(label: 'About'),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  trailing: Text(
                    AppConstants.appVersion,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Sign Out ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Sign Out',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showRolePicker(BuildContext context, String currentRole) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Role',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...[AppConstants.roleHouseOwner, AppConstants.roleContractor]
                .map((role) => ListTile(
                      leading: Icon(
                        role == AppConstants.roleHouseOwner
                            ? Icons.home_outlined
                            : Icons.engineering_outlined,
                        color: role == currentRole
                            ? AppTheme.primaryColor
                            : null,
                      ),
                      title: Text(role),
                      trailing: role == currentRole
                          ? const Icon(Icons.check,
                              color: AppTheme.primaryColor)
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        await ref
                            .read(authNotifierProvider.notifier)
                            .updateProfile(role: role);
                      },
                    )),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: selected ? AppTheme.primaryColor : null),
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
          : null,
      onTap: onTap,
    );
  }
}

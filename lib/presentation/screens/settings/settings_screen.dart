import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../main.dart';

// Maps locale code → (display name, Gemini language name, native label)
const _supportedLanguages = [
  ('en', 'English',  'English'),
  ('hi', 'Hindi',    'हिन्दी'),
  ('kn', 'Kannada',  'ಕನ್ನಡ'),
];

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
    final l10n = context.l10n;
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (!mounted) return;
      if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.photoLibraryDenied),
            action: SnackBarAction(
                label: l10n.openSettings, onPressed: openAppSettings),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.photoLibraryRequired)),
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
          SnackBar(content: Text(context.l10n.profilePhotoUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.failedUpdatePhoto(e.toString()))),
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
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.l10n.passwordResetSentTo(email))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(context.l10n.failedSendResetEmail(e.toString()))),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutTitle),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.signOut),
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

  /// Changes app UI locale + Gemini output language atomically.
  Future<void> _setLanguage(String code, String geminiName) async {
    await Hive.box(AppConstants.settingsBox)
        .put(AppConstants.languageKey, code);
    ref.read(localProvider.notifier).state = Locale(code);
    await ref
        .read(authNotifierProvider.notifier)
        .updateProfile(preferredLanguage: geminiName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userAsync = ref.watch(currentUserModelProvider);
    final authState = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localProvider);
    final theme = Theme.of(context);

    final currentThemeKey = themeMode == ThemeMode.dark
        ? 'dark'
        : themeMode == ThemeMode.light
            ? 'light'
            : 'system';

    final notificationsEnabled = Hive.box(AppConstants.settingsBox)
        .get(AppConstants.notificationsKey, defaultValue: true) as bool;

    // Find the display tuple for the current locale
    final currentLang = _supportedLanguages.firstWhere(
      (t) => t.$1 == currentLocale.languageCode,
      orElse: () => _supportedLanguages.first,
    );

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: l10n.saving,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.settingsTitle)),
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
                  label: Text(l10n.signOut,
                      style: const TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red)),
                ),
              ],
            ),
          ),
          error: (e, _) => Center(child: Text('${l10n.error}: $e')),
          data: (user) {
            if (user == null) {
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
                            ? l10n.settingUpAccount
                            : l10n.notLoggedIn,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (firebaseUser != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          firebaseUser.email ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
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
                        label: Text(l10n.signOut,
                            style: const TextStyle(color: Colors.red)),
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
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
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
                                decoration: InputDecoration(
                                  labelText: l10n.displayName,
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
                              tooltip: l10n.save,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => _isEditingName = false),
                              tooltip: l10n.cancel,
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
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
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
                _SectionHeader(label: l10n.account),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(l10n.role),
                  subtitle: Text(user.role),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => _showRolePicker(context, user.role),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset_outlined),
                  title: Text(l10n.changePassword),
                  subtitle: Text(l10n.sendResetLink),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => _sendPasswordReset(user.email),
                ),

                // ── Language ──────────────────────────────────────────
                _SectionHeader(label: l10n.language),
                ListTile(
                  leading: const Icon(Icons.translate_outlined),
                  title: Text(l10n.appLanguage),
                  subtitle: Text(
                      '${currentLang.$2} · ${currentLang.$3}'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => _showLanguagePicker(context, currentLocale.languageCode),
                ),

                // ── Appearance ────────────────────────────────────────
                _SectionHeader(label: l10n.appearance),
                _ThemeOption(
                  label: l10n.systemDefault,
                  icon: Icons.brightness_auto_outlined,
                  selected: currentThemeKey == 'system',
                  onTap: () => _setTheme('system'),
                ),
                _ThemeOption(
                  label: l10n.lightMode,
                  icon: Icons.wb_sunny_outlined,
                  selected: currentThemeKey == 'light',
                  onTap: () => _setTheme('light'),
                ),
                _ThemeOption(
                  label: l10n.darkMode,
                  icon: Icons.nightlight_outlined,
                  selected: currentThemeKey == 'dark',
                  onTap: () => _setTheme('dark'),
                ),

                // ── Notifications ─────────────────────────────────────
                _SectionHeader(label: l10n.notifications),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: Text(l10n.analysisResults),
                  subtitle: Text(l10n.notifiedWhenComplete),
                  value: notificationsEnabled,
                  onChanged: _setNotifications,
                  activeThumbColor: AppTheme.primaryColor,
                ),

                // ── About ─────────────────────────────────────────────
                _SectionHeader(label: l10n.about),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.version),
                  trailing: Text(
                    AppConstants.appVersion,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
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
                      label: Text(l10n.signOut,
                          style: const TextStyle(color: Colors.red)),
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

  void _showLanguagePicker(BuildContext context, String currentCode) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.languagePickerTitle,
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              l10n.languagePickerSubtitle,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 16),
            ...(_supportedLanguages.map((lang) {
              final isSelected = lang.$1 == currentCode;
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.08),
                  child: Text(
                    lang.$3[0],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                title: Text(lang.$2),
                subtitle: Text(lang.$3),
                trailing: isSelected
                    ? const Icon(Icons.check_circle,
                        color: AppTheme.primaryColor)
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _setLanguage(lang.$1, lang.$2);
                },
              );
            })),
          ],
        ),
      ),
    );
  }

  void _showRolePicker(BuildContext context, String currentRole) {
    final l10n = context.l10n;
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
            Text(l10n.selectRole,
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

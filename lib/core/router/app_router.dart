import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/phone_auth_screen.dart';
import '../../presentation/screens/projects/projects_home_screen.dart';
import '../../presentation/screens/projects/project_detail_screen.dart';
import '../../presentation/screens/projects/create_project_screen.dart';
import '../../presentation/screens/analysis/camera_picker_screen.dart';
import '../../presentation/screens/analysis/analysis_result_screen.dart';
import '../../presentation/screens/analysis/analysis_history_screen.dart';
import '../../presentation/screens/checklist/checklist_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

// Route name constants
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const projects = '/projects';
  static const projectDetail = '/projects/:projectId';
  static const createProject = '/projects/create';
  static const camera = '/projects/:projectId/camera';
  static const analysisResult = '/projects/:projectId/analysis/:imageId';
  static const analysisHistory = '/projects/:projectId/history';
  static const checklist = '/projects/:projectId/checklist';
  static const phoneAuth = '/phone-auth';
  static const settings = '/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  // RouterNotifier bridges Riverpod auth state → GoRouter refreshListenable.
  // The router is created ONCE; only the redirect logic re-runs on auth changes.
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.value != null;
      final isLoading = authState.isLoading;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isLogin = state.matchedLocation == AppRoutes.login;
      final isPhoneAuth = state.matchedLocation == AppRoutes.phoneAuth;

      if (isLoading) return isSplash ? null : AppRoutes.splash;

      final onboardingDone = Hive.box(AppConstants.settingsBox)
          .get(AppConstants.onboardingKey, defaultValue: false) as bool;

      if (isSplash) {
        if (!isAuthenticated) {
          return onboardingDone ? AppRoutes.login : AppRoutes.onboarding;
        }
        return AppRoutes.projects;
      }

      if (!isAuthenticated) {
        if (isLogin || isOnboarding || isPhoneAuth) return null;
        return AppRoutes.login;
      }

      if (isAuthenticated &&
          (isLogin || isOnboarding || isPhoneAuth)) {
        return AppRoutes.projects;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (ctx, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneAuth,
        builder: (ctx, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.projects,
        builder: (ctx, state) => const ProjectsHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.createProject,
        builder: (ctx, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: AppRoutes.projectDetail,
        builder: (ctx, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectDetailScreen(projectId: projectId);
        },
        routes: [
          GoRoute(
            path: 'camera',
            builder: (ctx, state) {
              final projectId = state.pathParameters['projectId']!;
              return CameraPickerScreen(projectId: projectId);
            },
          ),
          GoRoute(
            path: 'analysis/:imageId',
            builder: (ctx, state) {
              final projectId = state.pathParameters['projectId']!;
              final imageId = state.pathParameters['imageId']!;
              return AnalysisResultScreen(
                projectId: projectId,
                imageId: imageId,
              );
            },
          ),
          GoRoute(
            path: 'history',
            builder: (ctx, state) {
              final projectId = state.pathParameters['projectId']!;
              return AnalysisHistoryScreen(projectId: projectId);
            },
          ),
          GoRoute(
            path: 'checklist',
            builder: (ctx, state) {
              final projectId = state.pathParameters['projectId']!;
              return ChecklistScreen(projectId: projectId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (ctx, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.projects),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Bridges Riverpod [authStateProvider] changes to GoRouter's refreshListenable.
/// Created once alongside the router — notifies GoRouter to re-run its redirect
/// without recreating the router instance.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

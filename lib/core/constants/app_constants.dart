class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'BuildSmart';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'AI-Powered Construction Assistant';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String projectsCollection = 'projects';
  static const String imagesCollection = 'images';
  static const String checklistCollection = 'checklist';
  static const String appContentCollection = 'appContent';
  static const String bestPracticesDoc = 'bestPractices';

  // Storage Paths
  static const String storageProjectImages = 'project_images';

  // Hive Box Names
  static const String checklistBox = 'checklist_box';
  static const String settingsBox = 'settings_box';
  static const String userBox = 'user_box';

  // Hive Keys
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_done';
  static const String userRoleKey = 'user_role';
  static const String notificationsKey = 'notifications_enabled';
  static const String languageKey = 'language_code';

  // Image Analysis Status
  static const String statusPending = 'pending';
  static const String statusComplete = 'complete';
  static const String statusError = 'error';

  // User Roles
  static const String roleHouseOwner = 'House Owner';
  static const String roleContractor = 'Contractor';

  // Overall Assessment
  static const String assessmentPass = 'PASS';
  static const String assessmentFail = 'FAIL';
  static const String assessmentWarning = 'WARNING';

  // Confidence Levels
  static const String confidenceHigh = 'HIGH';
  static const String confidenceMedium = 'MEDIUM';
  static const String confidenceLow = 'LOW';

  // Error Codes
  static const String nonConstructionImageError = 'NON_CONSTRUCTION_IMAGE';

  // Pagination
  static const int projectsPageSize = 20;
  static const int imagesPageSize = 20;

  // Image Compression
  static const int imageMaxWidth = 1920;
  static const int imageMaxHeight = 1080;
  static const int imageQuality = 85;
  static const int imageMaxSizeKB = 2048;

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration analysisTimeout = Duration(minutes: 2);

  // FCM Topics
  static const String fcmTopicAll = 'all_users';

  // Notification Channels
  static const String notificationChannelId = 'buildsmart_channel';
  static const String notificationChannelName = 'BuildSmart Notifications';
  static const String notificationChannelDesc = 'Construction analysis results and updates';
}

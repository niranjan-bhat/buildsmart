// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BuildSmart';

  @override
  String get appTagline => 'AI-Powered Construction Assistant';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get or => 'or';

  @override
  String get settings => 'Settings';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signUp => 'Sign up';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get createAccount => 'Create Account';

  @override
  String get creatingAccount => 'Creating account...';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to your BuildSmart account';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signInLink => 'Sign in';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordValidation => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get enterEmailFirst => 'Enter your email first';

  @override
  String get passwordResetSent => 'Password reset email sent!';

  @override
  String passwordResetSentTo(String email) {
    return 'Password reset email sent to $email';
  }

  @override
  String failedSendResetEmail(String error) {
    return 'Failed to send reset email: $error';
  }

  @override
  String get createAccountTitle => 'Create account';

  @override
  String get createAccountSubtitle =>
      'Start tracking your construction projects';

  @override
  String get iAm => 'I am a';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameValidation => 'Enter your full name';

  @override
  String get continueWithPhone => 'Continue with Phone';

  @override
  String get phoneAuthTitle => 'Phone Sign-In';

  @override
  String get phoneAuthSubtitle => 'We\'ll send a one-time code to your number';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneNumberInvalid => 'Enter a valid phone number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get sendingOtp => 'Sending OTP…';

  @override
  String get enterOtpTitle => 'Enter OTP';

  @override
  String get otpSentTo => 'Code sent to';

  @override
  String get verifyOtp => 'Verify';

  @override
  String get verifyingOtp => 'Verifying…';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String resendOtpIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get newProject => 'New Project';

  @override
  String get createProject => 'Create Project';

  @override
  String get creatingProject => 'Creating project...';

  @override
  String get projectDetails => 'Project Details';

  @override
  String get projectDetailsSubtitle =>
      'Fill in the details to create a new construction project.';

  @override
  String get projectNameRequired => 'Project Name *';

  @override
  String get projectNameHint => 'e.g. My New House, Office Block A';

  @override
  String get projectNameValidation => 'Enter a project name (min 3 characters)';

  @override
  String get projectNotFound => 'Project not found';

  @override
  String get deleteProject => 'Delete Project';

  @override
  String get deleteProjectTitle => 'Delete Project?';

  @override
  String deleteProjectConfirm(String projectName) {
    return 'Are you sure you want to delete \"$projectName\"? This cannot be undone.';
  }

  @override
  String get failedLoadProjects => 'Failed to load projects';

  @override
  String get noProjectsTitle => 'No projects yet';

  @override
  String get noProjectsDescription =>
      'Create your first construction project to start tracking progress and analyzing images with AI.';

  @override
  String get locationLabel => 'Location';

  @override
  String get locationHint => 'e.g. City, Country';

  @override
  String get locationNotSet => 'Not set';

  @override
  String get locationNotSetDefault => 'Location not set';

  @override
  String get detectLocation => 'Detect location';

  @override
  String get locationServicesDisabled => 'Location services are disabled.';

  @override
  String get locationPermissionDenied => 'Location permission denied.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission permanently denied.';

  @override
  String failedGetLocation(String error) {
    return 'Failed to get location: $error';
  }

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'Brief description of the project...';

  @override
  String get noDescription => 'No description';

  @override
  String get createdLabel => 'Created';

  @override
  String get totalAnalyses => 'Total Analyses';

  @override
  String get totalDefects => 'Total Defects';

  @override
  String get recentTab => 'Recent';

  @override
  String get stagesTab => 'Stages';

  @override
  String get infoTab => 'Info';

  @override
  String get history => 'History';

  @override
  String get checklist => 'Checklist';

  @override
  String get loadingProject => 'Loading project...';

  @override
  String get inProgress => 'In Progress';

  @override
  String get done => 'Done';

  @override
  String get sameDay => 'Same day';

  @override
  String startedLabel(String date) {
    return 'Started $date';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get analyseImage => 'Analyse Image';

  @override
  String get analyseImages => 'Analyse Images';

  @override
  String get analyseWithAI => 'Analyse with AI';

  @override
  String analyseWithAIMultiple(int count) {
    return 'Analyse $count Images with AI';
  }

  @override
  String get aiAnalysing => 'AI is analysing your image...';

  @override
  String get usuallyTakes => 'This usually takes 10–20 seconds';

  @override
  String get tapToSelectImages => 'Tap to select images';

  @override
  String upToMaxPhotos(int max) {
    return 'Up to $max photos';
  }

  @override
  String imageSelectionHint(int max) {
    return 'Select up to $max photos. Each image is analysed independently — you will see a result for every photo.';
  }

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String galleryLeft(int remaining) {
    return 'Gallery ($remaining left)';
  }

  @override
  String imagesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images selected',
      one: '$count image selected',
    );
    return '$_temp0';
  }

  @override
  String uploadedCount(int completed, int total) {
    return '$completed/$total uploaded';
  }

  @override
  String imagesUploading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images uploading',
      one: '$count image uploading',
    );
    return '$_temp0 — AI is analysing each one.';
  }

  @override
  String failedCaptureImage(String error) {
    return 'Failed to capture image: $error';
  }

  @override
  String failedPickImages(String error) {
    return 'Failed to pick images: $error';
  }

  @override
  String get cameraPermissionRequired => 'Camera permission is required.';

  @override
  String get cameraPermissionPermanentlyDenied =>
      'Camera permission permanently denied. Enable it in Settings.';

  @override
  String get photoLibraryPermissionRequired =>
      'Photo library permission is required.';

  @override
  String get photoLibraryPermissionPermanentlyDenied =>
      'Photo library permission permanently denied. Enable it in Settings.';

  @override
  String get noImagesTitle => 'No images yet';

  @override
  String get noImagesDescription => 'Tap the camera button to analyse a photo';

  @override
  String get analysisFailed => 'Analysis Failed';

  @override
  String get nonConstructionError =>
      'This image does not appear to show a construction scene. Please upload a photo of the actual construction site.';

  @override
  String get deleteImageHint =>
      'Delete this image and try again with a clearer construction photo.';

  @override
  String get analysisResult => 'Analysis Result';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportAsPdf => 'Export as PDF';

  @override
  String get backToProject => 'Back to Project';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noCriticalIssues => 'No critical issues found';

  @override
  String issuesDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count issues detected',
      one: '$count issue detected',
    );
    return '$_temp0';
  }

  @override
  String get defectsFound => 'Defects Found';

  @override
  String get noDefectsDetected => 'No defects detected! This stage looks good.';

  @override
  String get bestPractices => 'Best Practices';

  @override
  String get notConstructionImageTitle => 'Not a Construction Image';

  @override
  String get notConstructionImageMsg =>
      'The uploaded image does not appear to be a construction site. Please try again with a relevant photo.';

  @override
  String get rectified => 'RECTIFIED';

  @override
  String get rectificationSteps => 'Rectification Steps';

  @override
  String get markAsRectified => 'Mark as Rectified';

  @override
  String get markAsUnresolved => 'Mark as Unresolved';

  @override
  String fixedCount(int fixed, int total) {
    return '$fixed/$total fixed';
  }

  @override
  String analysisCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count analyses',
      one: '$count analysis',
    );
    return '$_temp0';
  }

  @override
  String defectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count defects',
      one: '$count defect',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get saving => 'Saving...';

  @override
  String get displayName => 'Display Name';

  @override
  String get settingUpAccount => 'Setting up your account…';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get account => 'Account';

  @override
  String get role => 'Role';

  @override
  String get changePassword => 'Change Password';

  @override
  String get sendResetLink => 'Send a reset link to your email';

  @override
  String get appearance => 'Appearance';

  @override
  String get systemDefault => 'System Default';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App Language';

  @override
  String get languagePickerTitle => 'Language';

  @override
  String get languagePickerSubtitle =>
      'Changes the app language and AI analysis output.';

  @override
  String get notifications => 'Notifications';

  @override
  String get analysisResults => 'Analysis Results';

  @override
  String get notifiedWhenComplete =>
      'Get notified when AI analysis is complete';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get profilePhotoUpdated => 'Profile photo updated.';

  @override
  String failedUpdatePhoto(String error) {
    return 'Failed to update photo: $error';
  }

  @override
  String get signOutTitle => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get selectRole => 'Select Role';

  @override
  String get photoLibraryDenied =>
      'Photo library permission permanently denied. Enable it in Settings.';

  @override
  String get photoLibraryRequired => 'Photo library permission is required.';

  @override
  String get checklistTitle => 'Checklist';

  @override
  String get noChecklistItems => 'No checklist items for this stage.';

  @override
  String get analysisHistory => 'Analysis History';

  @override
  String get noAnalysesYet => 'No analyses yet';

  @override
  String get uploadToTrack => 'Upload images to start tracking your project';

  @override
  String get noResultsMatchFilters => 'No results match the filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get clearAll => 'Clear All';

  @override
  String get constructionStage => 'Construction Stage';

  @override
  String get assessment => 'Assessment';

  @override
  String get filters => 'Filters';

  @override
  String get clear => 'Clear';

  @override
  String get ofStages => 'of 11';
}

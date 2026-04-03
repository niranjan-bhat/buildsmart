import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BuildSmart'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Construction Assistant'**
  String get appTagline;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get creatingAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your BuildSmart account'**
  String get signInSubtitle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordValidation;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email first'**
  String get enterEmailFirst;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent!'**
  String get passwordResetSent;

  /// No description provided for @passwordResetSentTo.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}'**
  String passwordResetSentTo(String email);

  /// No description provided for @failedSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email: {error}'**
  String failedSendResetEmail(String error);

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your construction projects'**
  String get createAccountSubtitle;

  /// No description provided for @iAm.
  ///
  /// In en, this message translates to:
  /// **'I am a'**
  String get iAm;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameValidation;

  /// No description provided for @continueWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with Phone'**
  String get continueWithPhone;

  /// No description provided for @phoneAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Sign-In'**
  String get phoneAuthTitle;

  /// No description provided for @phoneAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a one-time code to your number'**
  String get phoneAuthSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get phoneNumberInvalid;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @sendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Sending OTP…'**
  String get sendingOtp;

  /// No description provided for @enterOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to'**
  String get otpSentTo;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyOtp;

  /// No description provided for @verifyingOtp.
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get verifyingOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @resendOtpIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendOtpIn(int seconds);

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get createProject;

  /// No description provided for @creatingProject.
  ///
  /// In en, this message translates to:
  /// **'Creating project...'**
  String get creatingProject;

  /// No description provided for @projectDetails.
  ///
  /// In en, this message translates to:
  /// **'Project Details'**
  String get projectDetails;

  /// No description provided for @projectDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details to create a new construction project.'**
  String get projectDetailsSubtitle;

  /// No description provided for @projectNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Project Name *'**
  String get projectNameRequired;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. My New House, Office Block A'**
  String get projectNameHint;

  /// No description provided for @projectNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a project name (min 3 characters)'**
  String get projectNameValidation;

  /// No description provided for @projectNotFound.
  ///
  /// In en, this message translates to:
  /// **'Project not found'**
  String get projectNotFound;

  /// No description provided for @deleteProject.
  ///
  /// In en, this message translates to:
  /// **'Delete Project'**
  String get deleteProject;

  /// No description provided for @deleteProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Project?'**
  String get deleteProjectTitle;

  /// No description provided for @deleteProjectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{projectName}\"? This cannot be undone.'**
  String deleteProjectConfirm(String projectName);

  /// No description provided for @failedLoadProjects.
  ///
  /// In en, this message translates to:
  /// **'Failed to load projects'**
  String get failedLoadProjects;

  /// No description provided for @noProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get noProjectsTitle;

  /// No description provided for @noProjectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first construction project to start tracking progress and analyzing images with AI.'**
  String get noProjectsDescription;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. City, Country'**
  String get locationHint;

  /// No description provided for @locationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get locationNotSet;

  /// No description provided for @locationNotSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get locationNotSetDefault;

  /// No description provided for @detectLocation.
  ///
  /// In en, this message translates to:
  /// **'Detect location'**
  String get detectLocation;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @failedGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location: {error}'**
  String failedGetLocation(String error);

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Brief description of the project...'**
  String get descriptionHint;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdLabel;

  /// No description provided for @totalAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Total Analyses'**
  String get totalAnalyses;

  /// No description provided for @totalDefects.
  ///
  /// In en, this message translates to:
  /// **'Total Defects'**
  String get totalDefects;

  /// No description provided for @recentTab.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentTab;

  /// No description provided for @stagesTab.
  ///
  /// In en, this message translates to:
  /// **'Stages'**
  String get stagesTab;

  /// No description provided for @infoTab.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTab;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @loadingProject.
  ///
  /// In en, this message translates to:
  /// **'Loading project...'**
  String get loadingProject;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @sameDay.
  ///
  /// In en, this message translates to:
  /// **'Same day'**
  String get sameDay;

  /// No description provided for @startedLabel.
  ///
  /// In en, this message translates to:
  /// **'Started {date}'**
  String startedLabel(String date);

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String durationDays(int count);

  /// No description provided for @analyseImage.
  ///
  /// In en, this message translates to:
  /// **'Analyse Image'**
  String get analyseImage;

  /// No description provided for @analyseImages.
  ///
  /// In en, this message translates to:
  /// **'Analyse Images'**
  String get analyseImages;

  /// No description provided for @analyseWithAI.
  ///
  /// In en, this message translates to:
  /// **'Analyse with AI'**
  String get analyseWithAI;

  /// No description provided for @analyseWithAIMultiple.
  ///
  /// In en, this message translates to:
  /// **'Analyse {count} Images with AI'**
  String analyseWithAIMultiple(int count);

  /// No description provided for @aiAnalysing.
  ///
  /// In en, this message translates to:
  /// **'AI is analysing your image...'**
  String get aiAnalysing;

  /// No description provided for @usuallyTakes.
  ///
  /// In en, this message translates to:
  /// **'This usually takes 10–20 seconds'**
  String get usuallyTakes;

  /// No description provided for @tapToSelectImages.
  ///
  /// In en, this message translates to:
  /// **'Tap to select images'**
  String get tapToSelectImages;

  /// No description provided for @upToMaxPhotos.
  ///
  /// In en, this message translates to:
  /// **'Up to {max} photos'**
  String upToMaxPhotos(int max);

  /// No description provided for @imageSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Select up to {max} photos. Each image is analysed independently — you will see a result for every photo.'**
  String imageSelectionHint(int max);

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @galleryLeft.
  ///
  /// In en, this message translates to:
  /// **'Gallery ({remaining} left)'**
  String galleryLeft(int remaining);

  /// No description provided for @imagesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} image selected} other{{count} images selected}}'**
  String imagesSelected(int count);

  /// No description provided for @uploadedCount.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} uploaded'**
  String uploadedCount(int completed, int total);

  /// No description provided for @imagesUploading.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} image uploading} other{{count} images uploading}} — AI is analysing each one.'**
  String imagesUploading(int count);

  /// No description provided for @failedCaptureImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image: {error}'**
  String failedCaptureImage(String error);

  /// No description provided for @failedPickImages.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick images: {error}'**
  String failedPickImages(String error);

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required.'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission permanently denied. Enable it in Settings.'**
  String get cameraPermissionPermanentlyDenied;

  /// No description provided for @photoLibraryPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo library permission is required.'**
  String get photoLibraryPermissionRequired;

  /// No description provided for @photoLibraryPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo library permission permanently denied. Enable it in Settings.'**
  String get photoLibraryPermissionPermanentlyDenied;

  /// No description provided for @noImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'No images yet'**
  String get noImagesTitle;

  /// No description provided for @noImagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the camera button to analyse a photo'**
  String get noImagesDescription;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis Failed'**
  String get analysisFailed;

  /// No description provided for @nonConstructionError.
  ///
  /// In en, this message translates to:
  /// **'This image does not appear to show a construction scene. Please upload a photo of the actual construction site.'**
  String get nonConstructionError;

  /// No description provided for @deleteImageHint.
  ///
  /// In en, this message translates to:
  /// **'Delete this image and try again with a clearer construction photo.'**
  String get deleteImageHint;

  /// No description provided for @analysisResult.
  ///
  /// In en, this message translates to:
  /// **'Analysis Result'**
  String get analysisResult;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPdf;

  /// No description provided for @backToProject.
  ///
  /// In en, this message translates to:
  /// **'Back to Project'**
  String get backToProject;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noCriticalIssues.
  ///
  /// In en, this message translates to:
  /// **'No critical issues found'**
  String get noCriticalIssues;

  /// No description provided for @issuesDetected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} issue detected} other{{count} issues detected}}'**
  String issuesDetected(int count);

  /// No description provided for @defectsFound.
  ///
  /// In en, this message translates to:
  /// **'Defects Found'**
  String get defectsFound;

  /// No description provided for @noDefectsDetected.
  ///
  /// In en, this message translates to:
  /// **'No defects detected! This stage looks good.'**
  String get noDefectsDetected;

  /// No description provided for @bestPractices.
  ///
  /// In en, this message translates to:
  /// **'Best Practices'**
  String get bestPractices;

  /// No description provided for @notConstructionImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Not a Construction Image'**
  String get notConstructionImageTitle;

  /// No description provided for @notConstructionImageMsg.
  ///
  /// In en, this message translates to:
  /// **'The uploaded image does not appear to be a construction site. Please try again with a relevant photo.'**
  String get notConstructionImageMsg;

  /// No description provided for @rectified.
  ///
  /// In en, this message translates to:
  /// **'RECTIFIED'**
  String get rectified;

  /// No description provided for @rectificationSteps.
  ///
  /// In en, this message translates to:
  /// **'Rectification Steps'**
  String get rectificationSteps;

  /// No description provided for @markAsRectified.
  ///
  /// In en, this message translates to:
  /// **'Mark as Rectified'**
  String get markAsRectified;

  /// No description provided for @markAsUnresolved.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unresolved'**
  String get markAsUnresolved;

  /// No description provided for @fixedCount.
  ///
  /// In en, this message translates to:
  /// **'{fixed}/{total} fixed'**
  String fixedCount(int fixed, int total);

  /// No description provided for @analysisCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} analysis} other{{count} analyses}}'**
  String analysisCount(int count);

  /// No description provided for @defectCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} defect} other{{count} defects}}'**
  String defectCount(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @settingUpAccount.
  ///
  /// In en, this message translates to:
  /// **'Setting up your account…'**
  String get settingUpAccount;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send a reset link to your email'**
  String get sendResetLink;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePickerTitle;

  /// No description provided for @languagePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Changes the app language and AI analysis output.'**
  String get languagePickerSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @analysisResults.
  ///
  /// In en, this message translates to:
  /// **'Analysis Results'**
  String get analysisResults;

  /// No description provided for @notifiedWhenComplete.
  ///
  /// In en, this message translates to:
  /// **'Get notified when AI analysis is complete'**
  String get notifiedWhenComplete;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get profilePhotoUpdated;

  /// No description provided for @failedUpdatePhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to update photo: {error}'**
  String failedUpdatePhoto(String error);

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutTitle;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @photoLibraryDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo library permission permanently denied. Enable it in Settings.'**
  String get photoLibraryDenied;

  /// No description provided for @photoLibraryRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo library permission is required.'**
  String get photoLibraryRequired;

  /// No description provided for @checklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklistTitle;

  /// No description provided for @noChecklistItems.
  ///
  /// In en, this message translates to:
  /// **'No checklist items for this stage.'**
  String get noChecklistItems;

  /// No description provided for @analysisHistory.
  ///
  /// In en, this message translates to:
  /// **'Analysis History'**
  String get analysisHistory;

  /// No description provided for @noAnalysesYet.
  ///
  /// In en, this message translates to:
  /// **'No analyses yet'**
  String get noAnalysesYet;

  /// No description provided for @uploadToTrack.
  ///
  /// In en, this message translates to:
  /// **'Upload images to start tracking your project'**
  String get uploadToTrack;

  /// No description provided for @noResultsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No results match the filters'**
  String get noResultsMatchFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @constructionStage.
  ///
  /// In en, this message translates to:
  /// **'Construction Stage'**
  String get constructionStage;

  /// No description provided for @assessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get assessment;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @ofStages.
  ///
  /// In en, this message translates to:
  /// **'of 11'**
  String get ofStages;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

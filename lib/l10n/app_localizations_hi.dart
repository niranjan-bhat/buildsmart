// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'BuildSmart';

  @override
  String get appTagline => 'AI-संचालित निर्माण सहायक';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get save => 'सहेजें';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get or => 'या';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'त्रुटि';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get signOut => 'साइन आउट करें';

  @override
  String get signUp => 'साइन अप करें';

  @override
  String get signingIn => 'साइन इन हो रहा है...';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get creatingAccount => 'खाता बनाया जा रहा है...';

  @override
  String get continueWithGoogle => 'Google से जारी रखें';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है';

  @override
  String get signInSubtitle => 'अपने BuildSmart खाते में साइन इन करें';

  @override
  String get noAccount => 'खाता नहीं है?';

  @override
  String get alreadyHaveAccount => 'पहले से खाता है?';

  @override
  String get signInLink => 'साइन इन करें';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get emailRequired => 'ईमेल आवश्यक है';

  @override
  String get emailInvalid => 'वैध ईमेल दर्ज करें';

  @override
  String get password => 'पासवर्ड';

  @override
  String get passwordRequired => 'पासवर्ड आवश्यक है';

  @override
  String get passwordValidation => 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get passwordsMismatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get enterEmailFirst => 'पहले अपना ईमेल दर्ज करें';

  @override
  String get passwordResetSent => 'पासवर्ड रीसेट ईमेल भेजा गया!';

  @override
  String passwordResetSentTo(String email) {
    return '$email पर पासवर्ड रीसेट ईमेल भेजा गया';
  }

  @override
  String failedSendResetEmail(String error) {
    return 'रीसेट ईमेल भेजने में विफल: $error';
  }

  @override
  String get createAccountTitle => 'खाता बनाएं';

  @override
  String get createAccountSubtitle =>
      'अपने निर्माण प्रोजेक्ट ट्रैक करना शुरू करें';

  @override
  String get iAm => 'मैं एक हूं';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get fullNameValidation => 'अपना पूरा नाम दर्ज करें';

  @override
  String get newProject => 'नया प्रोजेक्ट';

  @override
  String get createProject => 'प्रोजेक्ट बनाएं';

  @override
  String get creatingProject => 'प्रोजेक्ट बनाया जा रहा है...';

  @override
  String get projectDetails => 'प्रोजेक्ट विवरण';

  @override
  String get projectDetailsSubtitle =>
      'नया निर्माण प्रोजेक्ट बनाने के लिए विवरण भरें।';

  @override
  String get projectNameRequired => 'प्रोजेक्ट नाम *';

  @override
  String get projectNameHint => 'जैसे मेरा नया घर, ऑफिस ब्लॉक A';

  @override
  String get projectNameValidation =>
      'प्रोजेक्ट नाम दर्ज करें (कम से कम 3 अक्षर)';

  @override
  String get projectNotFound => 'प्रोजेक्ट नहीं मिला';

  @override
  String get deleteProject => 'प्रोजेक्ट हटाएं';

  @override
  String get deleteProjectTitle => 'प्रोजेक्ट हटाएं?';

  @override
  String deleteProjectConfirm(String projectName) {
    return 'क्या आप \"$projectName\" को हटाना चाहते हैं? यह पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get failedLoadProjects => 'प्रोजेक्ट लोड करने में विफल';

  @override
  String get noProjectsTitle => 'अभी कोई प्रोजेक्ट नहीं';

  @override
  String get noProjectsDescription =>
      'AI के साथ प्रगति ट्रैक करने और छवियों का विश्लेषण करने के लिए अपना पहला निर्माण प्रोजेक्ट बनाएं।';

  @override
  String get locationLabel => 'स्थान';

  @override
  String get locationHint => 'जैसे शहर, देश';

  @override
  String get locationNotSet => 'निर्धारित नहीं';

  @override
  String get locationNotSetDefault => 'स्थान निर्धारित नहीं';

  @override
  String get detectLocation => 'स्थान पहचानें';

  @override
  String get locationServicesDisabled => 'स्थान सेवाएं अक्षम हैं।';

  @override
  String get locationPermissionDenied => 'स्थान अनुमति अस्वीकृत।';

  @override
  String get locationPermissionPermanentlyDenied =>
      'स्थान अनुमति स्थायी रूप से अस्वीकृत।';

  @override
  String failedGetLocation(String error) {
    return 'स्थान प्राप्त करने में विफल: $error';
  }

  @override
  String get description => 'विवरण';

  @override
  String get descriptionHint => 'प्रोजेक्ट का संक्षिप्त विवरण...';

  @override
  String get noDescription => 'कोई विवरण नहीं';

  @override
  String get createdLabel => 'बनाया गया';

  @override
  String get totalAnalyses => 'कुल विश्लेषण';

  @override
  String get totalDefects => 'कुल दोष';

  @override
  String get recentTab => 'हाल के';

  @override
  String get stagesTab => 'चरण';

  @override
  String get infoTab => 'जानकारी';

  @override
  String get history => 'इतिहास';

  @override
  String get checklist => 'चेकलिस्ट';

  @override
  String get loadingProject => 'प्रोजेक्ट लोड हो रहा है...';

  @override
  String get inProgress => 'जारी है';

  @override
  String get done => 'पूर्ण';

  @override
  String get sameDay => 'उसी दिन';

  @override
  String startedLabel(String date) {
    return '$date को शुरू हुआ';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '$count दिन',
    );
    return '$_temp0';
  }

  @override
  String get analyseImage => 'छवि का विश्लेषण करें';

  @override
  String get analyseImages => 'छवियों का विश्लेषण करें';

  @override
  String get analyseWithAI => 'AI से विश्लेषण करें';

  @override
  String analyseWithAIMultiple(int count) {
    return '$count छवियों का AI से विश्लेषण करें';
  }

  @override
  String get aiAnalysing => 'AI आपकी छवि का विश्लेषण कर रहा है...';

  @override
  String get usuallyTakes => 'इसमें सामान्यतः 10–20 सेकंड लगते हैं';

  @override
  String get tapToSelectImages => 'छवियां चुनने के लिए टैप करें';

  @override
  String upToMaxPhotos(int max) {
    return 'अधिकतम $max फ़ोटो';
  }

  @override
  String imageSelectionHint(int max) {
    return 'अधिकतम $max फ़ोटो चुनें। प्रत्येक छवि का स्वतंत्र रूप से विश्लेषण किया जाएगा।';
  }

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String galleryLeft(int remaining) {
    return 'गैलरी ($remaining शेष)';
  }

  @override
  String imagesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियां चुनी गई',
      one: '$count छवि चुनी गई',
    );
    return '$_temp0';
  }

  @override
  String uploadedCount(int completed, int total) {
    return '$completed/$total अपलोड हुए';
  }

  @override
  String imagesUploading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियां अपलोड हो रही हैं',
      one: '$count छवि अपलोड हो रही है',
    );
    return '$_temp0 — AI विश्लेषण कर रहा है।';
  }

  @override
  String failedCaptureImage(String error) {
    return 'छवि कैप्चर करने में विफल: $error';
  }

  @override
  String failedPickImages(String error) {
    return 'छवियां चुनने में विफल: $error';
  }

  @override
  String get cameraPermissionRequired => 'कैमरा अनुमति आवश्यक है।';

  @override
  String get cameraPermissionPermanentlyDenied =>
      'कैमरा अनुमति स्थायी रूप से अस्वीकृत। सेटिंग्स में सक्षम करें।';

  @override
  String get photoLibraryPermissionRequired =>
      'फ़ोटो लाइब्रेरी अनुमति आवश्यक है।';

  @override
  String get photoLibraryPermissionPermanentlyDenied =>
      'फ़ोटो लाइब्रेरी अनुमति स्थायी रूप से अस्वीकृत। सेटिंग्स में सक्षम करें।';

  @override
  String get noImagesTitle => 'अभी कोई छवि नहीं';

  @override
  String get noImagesDescription =>
      'फ़ोटो का विश्लेषण करने के लिए कैमरा बटन टैप करें';

  @override
  String get analysisFailed => 'विश्लेषण विफल';

  @override
  String get nonConstructionError =>
      'यह छवि निर्माण स्थल की नहीं लगती। कृपया वास्तविक निर्माण स्थल की फ़ोटो अपलोड करें।';

  @override
  String get deleteImageHint =>
      'इस छवि को हटाएं और स्पष्ट निर्माण फ़ोटो के साथ पुनः प्रयास करें।';

  @override
  String get analysisResult => 'विश्लेषण परिणाम';

  @override
  String get exportPdf => 'PDF निर्यात करें';

  @override
  String get exportAsPdf => 'PDF के रूप में निर्यात करें';

  @override
  String get backToProject => 'प्रोजेक्ट पर वापस';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get noCriticalIssues => 'कोई गंभीर समस्या नहीं मिली';

  @override
  String issuesDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count समस्याएं पाई गईं',
      one: '$count समस्या पाई गई',
    );
    return '$_temp0';
  }

  @override
  String get defectsFound => 'दोष पाए गए';

  @override
  String get noDefectsDetected => 'कोई दोष नहीं मिला! यह चरण ठीक दिखता है।';

  @override
  String get bestPractices => 'सर्वोत्तम प्रथाएं';

  @override
  String get notConstructionImageTitle => 'निर्माण छवि नहीं';

  @override
  String get notConstructionImageMsg =>
      'अपलोड की गई छवि निर्माण स्थल की नहीं लगती। कृपया उचित फ़ोटो के साथ पुनः प्रयास करें।';

  @override
  String get rectified => 'सुधारा गया';

  @override
  String get rectificationSteps => 'सुधार के चरण';

  @override
  String get markAsRectified => 'सुधारित के रूप में चिह्नित करें';

  @override
  String get markAsUnresolved => 'अनसुलझे के रूप में चिह्नित करें';

  @override
  String fixedCount(int fixed, int total) {
    return '$fixed/$total सुधारे गए';
  }

  @override
  String analysisCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count विश्लेषण',
      one: '$count विश्लेषण',
    );
    return '$_temp0';
  }

  @override
  String defectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दोष',
      one: '$count दोष',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get saving => 'सहेजा जा रहा है...';

  @override
  String get displayName => 'प्रदर्शन नाम';

  @override
  String get settingUpAccount => 'आपका खाता सेट हो रहा है…';

  @override
  String get notLoggedIn => 'लॉग इन नहीं है';

  @override
  String get account => 'खाता';

  @override
  String get role => 'भूमिका';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get sendResetLink => 'अपने ईमेल पर रीसेट लिंक भेजें';

  @override
  String get appearance => 'दिखावट';

  @override
  String get systemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get lightMode => 'लाइट मोड';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get language => 'भाषा';

  @override
  String get appLanguage => 'ऐप भाषा';

  @override
  String get languagePickerTitle => 'भाषा';

  @override
  String get languagePickerSubtitle =>
      'ऐप की भाषा और AI विश्लेषण आउटपुट बदलता है।';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get analysisResults => 'विश्लेषण परिणाम';

  @override
  String get notifiedWhenComplete => 'AI विश्लेषण पूर्ण होने पर सूचित करें';

  @override
  String get about => 'के बारे में';

  @override
  String get version => 'संस्करण';

  @override
  String get profilePhotoUpdated => 'प्रोफ़ाइल फ़ोटो अपडेट की गई।';

  @override
  String failedUpdatePhoto(String error) {
    return 'फ़ोटो अपडेट करने में विफल: $error';
  }

  @override
  String get signOutTitle => 'साइन आउट करें';

  @override
  String get signOutConfirm => 'क्या आप साइन आउट करना चाहते हैं?';

  @override
  String get selectRole => 'भूमिका चुनें';

  @override
  String get photoLibraryDenied =>
      'फ़ोटो लाइब्रेरी अनुमति स्थायी रूप से अस्वीकृत। सेटिंग्स में सक्षम करें।';

  @override
  String get photoLibraryRequired => 'फ़ोटो लाइब्रेरी अनुमति आवश्यक है।';

  @override
  String get checklistTitle => 'चेकलिस्ट';

  @override
  String get noChecklistItems => 'इस चरण के लिए कोई चेकलिस्ट आइटम नहीं।';

  @override
  String get analysisHistory => 'विश्लेषण इतिहास';

  @override
  String get noAnalysesYet => 'अभी कोई विश्लेषण नहीं';

  @override
  String get uploadToTrack =>
      'अपने प्रोजेक्ट को ट्रैक करने के लिए छवियां अपलोड करें';

  @override
  String get noResultsMatchFilters => 'फ़िल्टर से कोई परिणाम नहीं मिला';

  @override
  String get clearFilters => 'फ़िल्टर साफ़ करें';

  @override
  String get clearAll => 'सभी साफ़ करें';

  @override
  String get constructionStage => 'निर्माण चरण';

  @override
  String get assessment => 'आकलन';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get ofStages => '11 में से';
}

import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/fcm_service.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final FcmService _fcmService;

  AuthRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
    required FcmService fcmService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _fcmService = fcmService;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  String? get currentUserId => _authService.currentUserId;

  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmailPassword(
      email: email,
      password: password,
    );
    return _getOrCreateUserModel(credential.user!);
  }

  Future<UserModel> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final credential = await _authService.registerWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    final user = credential.user!;
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? email,
      displayName: displayName,
      photoUrl: user.photoURL,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createUser(userModel);
    await _updateFcmToken(userModel.uid);
    return userModel;
  }

  Future<UserModel> signInWithGoogle({String role = AppConstants.roleHouseOwner}) async {
    final credential = await _authService.signInWithGoogle();
    final user = credential.user!;

    // Check if user already exists
    final existingUser = await _firestoreService.getUser(user.uid);
    if (existingUser != null) {
      await _updateFcmToken(user.uid);
      return existingUser;
    }

    // Create new user
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      photoUrl: user.photoURL,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createUser(userModel);
    await _updateFcmToken(user.uid);
    return userModel;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<UserModel?> getCurrentUserModel() async {
    final user = _authService.currentUser;
    if (user == null) return null;
    return _firestoreService.getUser(user.uid);
  }

  Stream<UserModel?> currentUserStream() {
    final userId = _authService.currentUserId;
    if (userId == null) return Stream.value(null);
    return _userStream(userId);
  }

  /// Emits `null` immediately so [StreamProvider] never stays in loading state,
  /// then follows with live Firestore data. Auto-creates the Firestore document
  /// if it is missing (e.g. registration write failed on a previous session).
  Stream<UserModel?> _userStream(String userId) async* {
    yield null; // immediate emission — UI shows recovery state, not spinner
    yield* _firestoreService.userStream(userId).asyncMap((userModel) async {
      if (userModel != null) return userModel;
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) return null;
      final recovered = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'User',
        photoUrl: firebaseUser.photoURL,
        role: AppConstants.roleHouseOwner,
        createdAt: DateTime.now(),
      );
      await _firestoreService.createUser(recovered);
      return recovered;
    });
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? role,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    final updates = <String, dynamic>{};
    if (displayName != null) {
      updates['displayName'] = displayName;
      await _authService.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
      await _authService.updatePhotoURL(photoUrl);
    }
    if (role != null) {
      updates['role'] = role;
    }

    if (updates.isNotEmpty) {
      await _firestoreService.updateUser(userId, updates);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<UserModel> _getOrCreateUserModel(User user) async {
    final existing = await _firestoreService.getUser(user.uid);
    if (existing != null) {
      await _updateFcmToken(user.uid);
      return existing;
    }

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      photoUrl: user.photoURL,
      role: AppConstants.roleHouseOwner,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createUser(userModel);
    await _updateFcmToken(user.uid);
    return userModel;
  }

  Future<void> _updateFcmToken(String userId) async {
    try {
      final token = await _fcmService.getToken();
      if (token != null) {
        await _firestoreService.updateFcmToken(userId, token);
      }
    } catch (_) {
      // Non-critical, ignore errors
    }
  }
}

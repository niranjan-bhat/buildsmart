import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/image_model.dart';
import '../models/analysis_result_model.dart';
import '../models/checklist_model.dart';
import '../../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Users ───────────────────────────────────────────────────────────────

  Future<void> createUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> userStream(String userId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update(data);
  }

  Future<void> updateFcmToken(String userId, String token) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .set({'fcmToken': token, 'updatedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true));
  }

  // ─── Projects ────────────────────────────────────────────────────────────

  Future<String> createProject(ProjectModel project) async {
    final docRef = await _db
        .collection(AppConstants.usersCollection)
        .doc(project.userId)
        .collection(AppConstants.projectsCollection)
        .add(project.toMap());
    return docRef.id;
  }

  Future<ProjectModel?> getProject(String userId, String projectId) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .get();
    if (!doc.exists) return null;
    return ProjectModel.fromFirestore(doc);
  }

  Stream<List<ProjectModel>> projectsStream(String userId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ProjectModel.fromFirestore(d)).toList());
  }

  Stream<ProjectModel?> projectStream(String userId, String projectId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .snapshots()
        .map((doc) => doc.exists ? ProjectModel.fromFirestore(doc) : null);
  }

  Future<void> updateProject(
      String userId, String projectId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .update(data);
  }

  Future<void> deleteProject(String userId, String projectId) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .delete();
  }

  Future<void> incrementProjectAnalysisCount(
      String userId, String projectId, int defectCount) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .update({
      'totalAnalyses': FieldValue.increment(1),
      'totalDefects': FieldValue.increment(defectCount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Images ──────────────────────────────────────────────────────────────

  Future<String> createImageRecord(ImageModel image) async {
    final docRef = await _db
        .collection(AppConstants.usersCollection)
        .doc(image.userId)
        .collection(AppConstants.projectsCollection)
        .doc(image.projectId)
        .collection(AppConstants.imagesCollection)
        .add(image.toMap());
    return docRef.id;
  }

  Future<ImageModel?> getImage(
      String userId, String projectId, String imageId) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection(AppConstants.imagesCollection)
        .doc(imageId)
        .get();
    if (!doc.exists) return null;
    return ImageModel.fromFirestore(doc);
  }

  Stream<ImageModel?> imageStream(
      String userId, String projectId, String imageId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection(AppConstants.imagesCollection)
        .doc(imageId)
        .snapshots()
        .map((doc) => doc.exists ? ImageModel.fromFirestore(doc) : null);
  }

  Stream<List<ImageModel>> imagesStream(String userId, String projectId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection(AppConstants.imagesCollection)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ImageModel.fromFirestore(d)).toList());
  }

  Future<void> updateImageStatus(
    String userId,
    String projectId,
    String imageId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection(AppConstants.imagesCollection)
        .doc(imageId)
        .update(data);
  }

  // ─── Analysis Results ────────────────────────────────────────────────────

  Future<AnalysisResultModel?> getAnalysisResult(
      String userId, String projectId, String resultId) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection('analysisResults')
        .doc(resultId)
        .get();
    if (!doc.exists) return null;
    return AnalysisResultModel.fromFirestore(doc);
  }

  Future<void> updateAnalysisDefects(
    String userId,
    String projectId,
    String resultId,
    List<Map<String, dynamic>> defects,
  ) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection('analysisResults')
        .doc(resultId)
        .update({'defects': defects});
  }

  Stream<List<AnalysisResultModel>> analysisResultsStream(
      String userId, String projectId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection('analysisResults')
        .orderBy('analyzedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AnalysisResultModel.fromFirestore(d)).toList());
  }

  // ─── Checklist ───────────────────────────────────────────────────────────

  Future<void> saveChecklist(
      String userId, String projectId, ChecklistStageModel checklist) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection(AppConstants.checklistCollection)
        .doc(checklist.stage)
        .set(checklist.toMap(), SetOptions(merge: true));
  }

  Future<ChecklistStageModel?> getChecklist(
      String userId, String projectId, String stage) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection(AppConstants.checklistCollection)
        .doc(stage)
        .get();
    if (!doc.exists) return null;
    return ChecklistStageModel.fromFirestore(doc);
  }

  Stream<ChecklistStageModel?> checklistStream(
      String userId, String projectId, String stage) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection(AppConstants.checklistCollection)
        .doc(stage)
        .snapshots()
        .map((doc) =>
            doc.exists ? ChecklistStageModel.fromFirestore(doc) : null);
  }

  Future<void> updateChecklistItem(
    String userId,
    String projectId,
    String stage,
    ChecklistItem item,
  ) async {
    final docRef = _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection(AppConstants.checklistCollection)
        .doc(stage);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) {
        transaction.set(docRef, {
          'stage': stage,
          'projectId': projectId,
          'items': [item.toMap()],
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        final data = doc.data() as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>?)
                ?.map((i) => ChecklistItem.fromMap(i as Map<String, dynamic>))
                .toList() ??
            [];
        final idx = items.indexWhere((i) => i.id == item.id);
        if (idx >= 0) {
          items[idx] = item;
        } else {
          items.add(item);
        }
        transaction.update(docRef, {
          'items': items.map((i) => i.toMap()).toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}

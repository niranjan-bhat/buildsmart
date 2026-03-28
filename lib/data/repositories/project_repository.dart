import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/construction_stages.dart';

class ProjectRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  ProjectRepository({
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService;

  Stream<List<ProjectModel>> getProjectsStream(String userId) {
    return _firestoreService.projectsStream(userId);
  }

  Stream<ProjectModel?> getProjectStream(String userId, String projectId) {
    return _firestoreService.projectStream(userId, projectId);
  }

  Future<ProjectModel> createProject({
    required String userId,
    required String name,
    required String description,
    required String location,
  }) async {
    if (userId.isEmpty) throw Exception('Not authenticated. Please sign in again.');

    final now = DateTime.now();
    final project = ProjectModel(
      id: '',
      userId: userId,
      name: name,
      description: description,
      location: location,
      currentStage: ConstructionStages.stages[0].name,
      currentStageIndex: 0,
      createdAt: now,
      stageHistory: {ConstructionStages.stages[0].name: now},
    );

    final id = await _firestoreService.createProject(project).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Request timed out. Check your connection and try again.'),
    );
    return project.copyWith(id: id);
  }

  Future<void> updateProject(
    String userId,
    String projectId,
    Map<String, dynamic> updates,
  ) async {
    await _firestoreService.updateProject(userId, projectId, updates);
  }

  Future<void> updateProjectStage(
    String userId,
    String projectId,
    String stageName,
    int stageIndex,
  ) async {
    await _firestoreService.updateProject(userId, projectId, {
      'currentStage': stageName,
      'currentStageIndex': stageIndex,
      'stageHistory.$stageName': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProjectThumbnail(
    String userId,
    String projectId,
    String thumbnailUrl,
  ) async {
    await _firestoreService.updateProject(userId, projectId, {
      'thumbnailUrl': thumbnailUrl,
    });
  }

  Future<void> deleteProject(String userId, String projectId) async {
    await _firestoreService.deleteProject(userId, projectId);
  }

  Future<ProjectModel?> getProject(String userId, String projectId) async {
    return _firestoreService.getProject(userId, projectId);
  }
}

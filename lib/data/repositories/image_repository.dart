import 'dart:io';
import '../models/image_model.dart';
import '../models/analysis_result_model.dart';
import '../models/defect_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/app_constants.dart';

class ImageRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  ImageRepository({
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService;

  /// Uploads image to Storage and creates a Firestore record with status:pending.
  /// The Cloud Function fires on the Firestore onCreate trigger.
  Future<ImageModel> uploadAndAnalyze({
    required String userId,
    required String projectId,
    required File imageFile,
    String language = 'English',
    void Function(double progress)? onProgress,
  }) async {
    // Upload to Storage
    final uploadResult = await _storageService.uploadProjectImage(
      userId: userId,
      projectId: projectId,
      imageFile: imageFile,
      onProgress: onProgress,
    );

    // Create Firestore record (triggers Cloud Function)
    final imageModel = ImageModel(
      id: '',
      projectId: projectId,
      userId: userId,
      storagePath: uploadResult.storagePath,
      downloadUrl: uploadResult.downloadUrl,
      status: AppConstants.statusPending,
      uploadedAt: DateTime.now(),
      fileSizeBytes: uploadResult.fileSizeBytes,
      language: language,
    );

    final imageId = await _firestoreService.createImageRecord(imageModel);

    // Keep project thumbnail up to date with the latest uploaded image
    await _firestoreService.updateProject(userId, projectId, {
      'thumbnailUrl': uploadResult.downloadUrl,
    });

    return imageModel.copyWith(id: imageId);
  }

  /// Real-time listener on a single image document.
  Stream<ImageModel?> getImageStream(
    String userId,
    String projectId,
    String imageId,
  ) {
    return _firestoreService.imageStream(userId, projectId, imageId);
  }

  Stream<List<ImageModel>> getImagesStream(String userId, String projectId) {
    return _firestoreService.imagesStream(userId, projectId);
  }

  Future<ImageModel?> getImage(
    String userId,
    String projectId,
    String imageId,
  ) async {
    return _firestoreService.getImage(userId, projectId, imageId);
  }

  Stream<List<AnalysisResultModel>> getAnalysisResultsStream(
    String userId,
    String projectId,
  ) {
    return _firestoreService.analysisResultsStream(userId, projectId);
  }

  Future<void> updateDefectRectification(
    String userId,
    String projectId,
    String resultId,
    List<DefectModel> defects,
  ) async {
    await _firestoreService.updateAnalysisDefects(
      userId,
      projectId,
      resultId,
      defects.map((d) => d.toMap()).toList(),
    );
  }

  Future<AnalysisResultModel?> getAnalysisResult(
    String userId,
    String projectId,
    String resultId,
  ) async {
    return _firestoreService.getAnalysisResult(userId, projectId, resultId);
  }
}

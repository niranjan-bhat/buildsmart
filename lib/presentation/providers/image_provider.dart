import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/image_model.dart';
import '../../data/models/analysis_result_model.dart';
import '../../data/repositories/image_repository.dart';
import 'auth_provider.dart';
import 'project_provider.dart';

// ─── Repository Provider ─────────────────────────────────────────────────────

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  return ImageRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

// ─── Stream Providers ────────────────────────────────────────────────────────

final imagesStreamProvider =
    StreamProvider.family<List<ImageModel>, String>((ref, projectId) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref
          .watch(imageRepositoryProvider)
          .getImagesStream(user.uid, projectId);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final imageStreamProvider =
    StreamProvider.family<ImageModel?, _ImageParams>((ref, params) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref
          .watch(imageRepositoryProvider)
          .getImageStream(user.uid, params.projectId, params.imageId);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final analysisResultsStreamProvider =
    StreamProvider.family<List<AnalysisResultModel>, String>((ref, projectId) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref
          .watch(imageRepositoryProvider)
          .getAnalysisResultsStream(user.uid, projectId);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// ─── Upload Notifier ─────────────────────────────────────────────────────────

class UploadState {
  final bool isUploading;
  final double uploadProgress;
  final String? error;
  final ImageModel? uploadedImage;
  final bool isAnalyzing;
  final AnalysisResultModel? analysisResult;
  final bool hasNonConstructionError;
  final int totalImages;
  final int completedUploads;
  final List<ImageModel> uploadedImages;

  const UploadState({
    this.isUploading = false,
    this.uploadProgress = 0,
    this.error,
    this.uploadedImage,
    this.isAnalyzing = false,
    this.analysisResult,
    this.hasNonConstructionError = false,
    this.totalImages = 1,
    this.completedUploads = 0,
    this.uploadedImages = const [],
  });

  UploadState copyWith({
    bool? isUploading,
    double? uploadProgress,
    String? error,
    ImageModel? uploadedImage,
    bool? isAnalyzing,
    AnalysisResultModel? analysisResult,
    bool? hasNonConstructionError,
    int? totalImages,
    int? completedUploads,
    List<ImageModel>? uploadedImages,
    bool clearError = false,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: clearError ? null : (error ?? this.error),
      uploadedImage: uploadedImage ?? this.uploadedImage,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      analysisResult: analysisResult ?? this.analysisResult,
      hasNonConstructionError:
          hasNonConstructionError ?? this.hasNonConstructionError,
      totalImages: totalImages ?? this.totalImages,
      completedUploads: completedUploads ?? this.completedUploads,
      uploadedImages: uploadedImages ?? this.uploadedImages,
    );
  }

  bool get isDone => !isUploading && !isAnalyzing;
  bool get isMultiUpload => totalImages > 1;
}

class UploadNotifier extends StateNotifier<UploadState> {
  final ImageRepository _repository;
  final String _userId;

  UploadNotifier(this._repository, this._userId) : super(const UploadState());

  Future<ImageModel?> uploadImage({
    required String projectId,
    required File imageFile,
    String language = 'English',
  }) async {
    state = const UploadState(isUploading: true, uploadProgress: 0);
    try {
      final imageModel = await _repository.uploadAndAnalyze(
        userId: _userId,
        projectId: projectId,
        imageFile: imageFile,
        language: language,
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );
      state = state.copyWith(
        isUploading: false,
        uploadProgress: 1.0,
        uploadedImage: imageModel,
        isAnalyzing: true,
      );
      return imageModel;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<List<ImageModel>> uploadImages({
    required String projectId,
    required List<File> imageFiles,
    String language = 'English',
  }) async {
    final total = imageFiles.length;
    state = UploadState(isUploading: true, uploadProgress: 0, totalImages: total);

    final uploaded = <ImageModel>[];
    final errors = <String>[];
    // Track per-file progress contribution
    final progresses = List<double>.filled(total, 0.0);

    await Future.wait(
      imageFiles.asMap().entries.map((entry) async {
        try {
          final model = await _repository.uploadAndAnalyze(
            userId: _userId,
            projectId: projectId,
            imageFile: entry.value,
            language: language,
            onProgress: (p) {
              progresses[entry.key] = p;
              final avg =
                  progresses.reduce((a, b) => a + b) / total;
              state = state.copyWith(uploadProgress: avg);
            },
          );
          uploaded.add(model);
          state = state.copyWith(
            completedUploads: state.completedUploads + 1,
          );
        } catch (e) {
          errors.add(e.toString().replaceFirst('Exception: ', ''));
        }
      }),
    );

    if (uploaded.isEmpty) {
      state = state.copyWith(
        isUploading: false,
        error: errors.isNotEmpty ? errors.first : 'Upload failed',
      );
      return [];
    }

    state = state.copyWith(
      isUploading: false,
      uploadProgress: 1.0,
      uploadedImages: uploaded,
      // Only enter "analysing" state for single-image flow
      isAnalyzing: total == 1,
      uploadedImage: total == 1 ? uploaded.first : null,
    );
    return uploaded;
  }

  void onAnalysisComplete(ImageModel image, AnalysisResultModel? result) {
    if (result != null) {
      state = state.copyWith(
        isAnalyzing: false,
        analysisResult: result,
        hasNonConstructionError: false,
      );
    } else if (image.isError) {
      state = state.copyWith(
        isAnalyzing: false,
        hasNonConstructionError: image.errorMessage?.contains('NON_CONSTRUCTION') ?? false,
        error: image.errorMessage,
      );
    }
  }

  void reset() {
    state = const UploadState();
  }
}

final uploadNotifierProvider =
    StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid ?? '';
  return UploadNotifier(ref.watch(imageRepositoryProvider), userId);
});

// ─── Helper class for family provider params ─────────────────────────────────

class _ImageParams {
  final String projectId;
  final String imageId;

  const _ImageParams({required this.projectId, required this.imageId});

  @override
  bool operator ==(Object other) =>
      other is _ImageParams &&
      other.projectId == projectId &&
      other.imageId == imageId;

  @override
  int get hashCode => Object.hash(projectId, imageId);
}

_ImageParams imageParams(String projectId, String imageId) =>
    _ImageParams(projectId: projectId, imageId: imageId);

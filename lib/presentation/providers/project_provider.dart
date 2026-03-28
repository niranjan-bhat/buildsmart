import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/services/storage_service.dart';
import 'auth_provider.dart';

// ─── Repository Provider ─────────────────────────────────────────────────────

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

// ─── Projects Stream ─────────────────────────────────────────────────────────

final projectsStreamProvider = StreamProvider<List<ProjectModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.watch(projectRepositoryProvider).getProjectsStream(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final projectStreamProvider =
    StreamProvider.family<ProjectModel?, String>((ref, projectId) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref
          .watch(projectRepositoryProvider)
          .getProjectStream(user.uid, projectId);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Project Notifier ────────────────────────────────────────────────────────

class ProjectState {
  final bool isLoading;
  final String? error;
  final ProjectModel? lastCreatedProject;

  const ProjectState({
    this.isLoading = false,
    this.error,
    this.lastCreatedProject,
  });

  ProjectState copyWith({
    bool? isLoading,
    String? error,
    ProjectModel? lastCreatedProject,
    bool clearError = false,
  }) {
    return ProjectState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastCreatedProject: lastCreatedProject ?? this.lastCreatedProject,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectState> {
  final ProjectRepository _repository;
  final String _userId;

  ProjectNotifier(this._repository, this._userId)
      : super(const ProjectState());

  Future<ProjectModel?> createProject({
    required String name,
    required String description,
    required String location,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final project = await _repository.createProject(
        userId: _userId,
        name: name,
        description: description,
        location: location,
      );
      state =
          state.copyWith(isLoading: false, lastCreatedProject: project);
      return project;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return null;
    }
  }

  Future<bool> updateProjectStage(
    String projectId,
    String stageName,
    int stageIndex,
  ) async {
    try {
      await _repository.updateProjectStage(
          _userId, projectId, stageName, stageIndex);
      return true;
    } catch (e) {
      state = state.copyWith(
          error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteProject(_userId, projectId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final projectNotifierProvider =
    StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid ?? '';
  return ProjectNotifier(ref.watch(projectRepositoryProvider), userId);
});

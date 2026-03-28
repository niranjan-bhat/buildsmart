import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/checklist_model.dart';
import '../../data/repositories/checklist_repository.dart';
import 'auth_provider.dart';

// ─── Repository Provider ─────────────────────────────────────────────────────

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  return ChecklistRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

// ─── Checklist Stream ────────────────────────────────────────────────────────

final checklistStreamProvider =
    StreamProvider.family<ChecklistStageModel?, _ChecklistParams>(
        (ref, params) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(checklistRepositoryProvider).getChecklistStream(
            userId: user.uid,
            projectId: params.projectId,
            stage: params.stage,
          );
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Checklist Notifier ──────────────────────────────────────────────────────

class ChecklistState {
  final Map<String, ChecklistStageModel> checklists;
  final bool isLoading;
  final String? error;

  const ChecklistState({
    this.checklists = const {},
    this.isLoading = false,
    this.error,
  });

  ChecklistState copyWith({
    Map<String, ChecklistStageModel>? checklists,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChecklistState(
      checklists: checklists ?? this.checklists,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChecklistNotifier extends StateNotifier<ChecklistState> {
  final ChecklistRepository _repository;
  final String _userId;

  ChecklistNotifier(this._repository, this._userId)
      : super(const ChecklistState());

  Future<void> loadChecklist({
    required String projectId,
    required String stage,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final checklist = await _repository.getChecklist(
        userId: _userId,
        projectId: projectId,
        stage: stage,
      );
      final updated = Map<String, ChecklistStageModel>.from(state.checklists);
      updated[_key(projectId, stage)] = checklist;
      state = state.copyWith(checklists: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> toggleItem({
    required String projectId,
    required String stage,
    required ChecklistItem item,
    required bool isCompleted,
  }) async {
    try {
      final updated = await _repository.toggleItem(
        userId: _userId,
        projectId: projectId,
        stage: stage,
        item: item,
        isCompleted: isCompleted,
      );
      final updatedMap = Map<String, ChecklistStageModel>.from(state.checklists);
      updatedMap[_key(projectId, stage)] = updated;
      state = state.copyWith(checklists: updatedMap);
    } catch (e) {
      state = state.copyWith(
          error: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  ChecklistStageModel? getChecklist(String projectId, String stage) {
    return state.checklists[_key(projectId, stage)];
  }

  String _key(String projectId, String stage) => '${projectId}_$stage';

  void clearError() => state = state.copyWith(clearError: true);
}

final checklistNotifierProvider =
    StateNotifierProvider<ChecklistNotifier, ChecklistState>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid ?? '';
  return ChecklistNotifier(ref.watch(checklistRepositoryProvider), userId);
});

// ─── Helper ──────────────────────────────────────────────────────────────────

class _ChecklistParams {
  final String projectId;
  final String stage;

  const _ChecklistParams({required this.projectId, required this.stage});

  @override
  bool operator ==(Object other) =>
      other is _ChecklistParams &&
      other.projectId == projectId &&
      other.stage == stage;

  @override
  int get hashCode => Object.hash(projectId, stage);
}

_ChecklistParams checklistParams(String projectId, String stage) =>
    _ChecklistParams(projectId: projectId, stage: stage);

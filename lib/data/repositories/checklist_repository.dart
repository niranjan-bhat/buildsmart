import 'package:hive_flutter/hive_flutter.dart';
import '../models/checklist_model.dart';
import '../services/firestore_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/construction_stages.dart';

class ChecklistRepository {
  final FirestoreService _firestoreService;

  ChecklistRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Gets checklist from Hive cache, falls back to Firestore, then builds default.
  Future<ChecklistStageModel> getChecklist({
    required String userId,
    required String projectId,
    required String stage,
  }) async {
    final cacheKey = _cacheKey(userId, projectId, stage);

    // Try Hive cache first
    final box = Hive.box<Map>(AppConstants.checklistBox);
    final cached = box.get(cacheKey);
    if (cached != null) {
      try {
        return ChecklistStageModel.fromMap(
          Map<String, dynamic>.from(cached),
        );
      } catch (_) {}
    }

    // Try Firestore
    final fromFirestore =
        await _firestoreService.getChecklist(userId, projectId, stage);
    if (fromFirestore != null) {
      await _cacheChecklist(cacheKey, fromFirestore);
      return fromFirestore;
    }

    // Build default checklist
    return _buildDefaultChecklist(projectId, stage);
  }

  Stream<ChecklistStageModel?> getChecklistStream({
    required String userId,
    required String projectId,
    required String stage,
  }) {
    return _firestoreService.checklistStream(userId, projectId, stage);
  }

  Future<ChecklistStageModel> toggleItem({
    required String userId,
    required String projectId,
    required String stage,
    required ChecklistItem item,
    required bool isCompleted,
  }) async {
    final updatedItem = item.copyWith(
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
      completedBy: isCompleted ? userId : null,
    );

    await _firestoreService.updateChecklistItem(
        userId, projectId, stage, updatedItem);

    // Update cache
    final cacheKey = _cacheKey(userId, projectId, stage);
    final current =
        await getChecklist(userId: userId, projectId: projectId, stage: stage);
    final idx = current.items.indexWhere((i) => i.id == item.id);
    final updatedItems = List<ChecklistItem>.from(current.items);
    if (idx >= 0) {
      updatedItems[idx] = updatedItem;
    }
    final updatedChecklist =
        current.copyWith(items: updatedItems, lastUpdated: DateTime.now());
    await _cacheChecklist(cacheKey, updatedChecklist);
    return updatedChecklist;
  }

  Future<void> saveChecklist({
    required String userId,
    required String projectId,
    required ChecklistStageModel checklist,
  }) async {
    await _firestoreService.saveChecklist(userId, projectId, checklist);
    final cacheKey = _cacheKey(userId, projectId, checklist.stage);
    await _cacheChecklist(cacheKey, checklist);
  }

  ChecklistStageModel _buildDefaultChecklist(String projectId, String stage) {
    final textItems = ConstructionStages.getChecklistItems(stage);
    final items = textItems.asMap().entries.map((entry) {
      return ChecklistItem(
        id: 'item_${stage.replaceAll(' ', '_').toLowerCase()}_${entry.key}',
        stage: stage,
        text: entry.value,
        isCompleted: false,
      );
    }).toList();

    return ChecklistStageModel(
      stage: stage,
      projectId: projectId,
      items: items,
    );
  }

  Future<void> _cacheChecklist(
      String cacheKey, ChecklistStageModel checklist) async {
    try {
      final box = Hive.box<Map>(AppConstants.checklistBox);
      await box.put(cacheKey, checklist.toMap().cast<String, dynamic>());
    } catch (_) {}
  }

  String _cacheKey(String userId, String projectId, String stage) {
    return '${userId}_${projectId}_$stage';
  }
}

/// Fake DocumentSnapshot for Hive deserialization
class _FakeDoc {
  final String _id;
  final Map<String, dynamic> _data;

  _FakeDoc(this._id, this._data);

  String get id => _id;

  Map<String, dynamic> data() => _data;

  bool get exists => true;
}

extension on ChecklistStageModel {
  static ChecklistStageModel fromFirestore(_FakeDoc doc) {
    return ChecklistStageModel(
      stage: doc._data['stage'] as String? ?? doc.id,
      projectId: doc._data['projectId'] as String? ?? '',
      items: (doc._data['items'] as List<dynamic>?)
              ?.map((i) =>
                  ChecklistItem.fromMap(Map<String, dynamic>.from(i as Map)))
              .toList() ??
          [],
    );
  }
}

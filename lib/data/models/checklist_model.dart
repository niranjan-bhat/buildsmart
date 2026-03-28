import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistItem {
  final String id;
  final String stage;
  final String text;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completedBy;

  const ChecklistItem({
    required this.id,
    required this.stage,
    required this.text,
    this.isCompleted = false,
    this.completedAt,
    this.completedBy,
  });

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String? ?? '',
      stage: map['stage'] as String? ?? '',
      text: map['text'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] is Timestamp
          ? (map['completedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['completedAt'] as String? ?? ''),
      completedBy: map['completedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stage': stage,
      'text': text,
      'isCompleted': isCompleted,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'completedBy': completedBy,
    };
  }

  ChecklistItem copyWith({
    String? id,
    String? stage,
    String? text,
    bool? isCompleted,
    DateTime? completedAt,
    String? completedBy,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      stage: stage ?? this.stage,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
    );
  }

  @override
  String toString() =>
      'ChecklistItem(id: $id, stage: $stage, completed: $isCompleted)';
}

class ChecklistStageModel {
  final String stage;
  final String projectId;
  final List<ChecklistItem> items;
  final DateTime? lastUpdated;

  const ChecklistStageModel({
    required this.stage,
    required this.projectId,
    required this.items,
    this.lastUpdated,
  });

  factory ChecklistStageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChecklistStageModel(
      stage: data['stage'] as String? ?? doc.id,
      projectId: data['projectId'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((i) => ChecklistItem.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  factory ChecklistStageModel.fromMap(Map<String, dynamic> data) {
    return ChecklistStageModel(
      stage: data['stage'] as String? ?? '',
      projectId: data['projectId'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((i) => ChecklistItem.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: _parseDateTime(data['lastUpdated']),
    );
  }
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'stage': stage,
      'projectId': projectId,
      'items': items.map((i) => i.toMap()).toList(),
      'lastUpdated':
          lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  int get completedCount => items.where((i) => i.isCompleted).length;
  int get totalCount => items.length;
  double get completionRate => totalCount > 0 ? completedCount / totalCount : 0;

  ChecklistStageModel copyWith({
    String? stage,
    String? projectId,
    List<ChecklistItem>? items,
    DateTime? lastUpdated,
  }) {
    return ChecklistStageModel(
      stage: stage ?? this.stage,
      projectId: projectId ?? this.projectId,
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

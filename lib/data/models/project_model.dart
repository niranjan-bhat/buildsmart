import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String location;
  final String currentStage;
  final int currentStageIndex;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? thumbnailUrl;
  final int totalAnalyses;
  final int totalDefects;
  // Maps stage name → DateTime when that stage was started
  final Map<String, DateTime> stageHistory;

  const ProjectModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.location,
    required this.currentStage,
    required this.currentStageIndex,
    required this.createdAt,
    this.updatedAt,
    this.thumbnailUrl,
    this.totalAnalyses = 0,
    this.totalDefects = 0,
    this.stageHistory = const {},
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawHistory = data['stageHistory'] as Map<String, dynamic>?;
    final stageHistory = <String, DateTime>{};
    if (rawHistory != null) {
      rawHistory.forEach((key, value) {
        if (value is Timestamp) stageHistory[key] = value.toDate();
      });
    }
    return ProjectModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: data['location'] as String? ?? '',
      currentStage: data['currentStage'] as String? ?? 'Site Preparation',
      currentStageIndex: data['currentStageIndex'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      thumbnailUrl: data['thumbnailUrl'] as String?,
      totalAnalyses: data['totalAnalyses'] as int? ?? 0,
      totalDefects: data['totalDefects'] as int? ?? 0,
      stageHistory: stageHistory,
    );
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    final rawHistory = map['stageHistory'] as Map<String, dynamic>?;
    final stageHistory = <String, DateTime>{};
    if (rawHistory != null) {
      rawHistory.forEach((key, value) {
        if (value is Timestamp) {
          stageHistory[key] = value.toDate();
        } else if (value is String) {
          final dt = DateTime.tryParse(value);
          if (dt != null) stageHistory[key] = dt;
        }
      });
    }
    return ProjectModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      currentStage: map['currentStage'] as String? ?? 'Site Preparation',
      currentStageIndex: map['currentStageIndex'] as int? ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt'] as String? ?? ''),
      thumbnailUrl: map['thumbnailUrl'] as String?,
      totalAnalyses: map['totalAnalyses'] as int? ?? 0,
      totalDefects: map['totalDefects'] as int? ?? 0,
      stageHistory: stageHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'location': location,
      'currentStage': currentStage,
      'currentStageIndex': currentStageIndex,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'thumbnailUrl': thumbnailUrl,
      'totalAnalyses': totalAnalyses,
      'totalDefects': totalDefects,
      'stageHistory': stageHistory.map(
        (k, v) => MapEntry(k, Timestamp.fromDate(v)),
      ),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? location,
    String? currentStage,
    int? currentStageIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnailUrl,
    int? totalAnalyses,
    int? totalDefects,
    Map<String, DateTime>? stageHistory,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      currentStage: currentStage ?? this.currentStage,
      currentStageIndex: currentStageIndex ?? this.currentStageIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      totalAnalyses: totalAnalyses ?? this.totalAnalyses,
      totalDefects: totalDefects ?? this.totalDefects,
      stageHistory: stageHistory ?? this.stageHistory,
    );
  }

  double get progressPercentage => (currentStageIndex + 1) / 11;

  @override
  String toString() =>
      'ProjectModel(id: $id, name: $name, currentStage: $currentStage)';
}

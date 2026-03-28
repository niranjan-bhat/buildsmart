import 'package:cloud_firestore/cloud_firestore.dart';
import 'defect_model.dart';

class AnalysisResultModel {
  final String id;
  final String imageId;
  final String projectId;
  final String userId;
  final String constructionStage;
  final String stageConfidence;
  final List<DefectModel> defects;
  final List<String> bestPractices;
  final String overallAssessment;
  final DateTime analyzedAt;
  final String? imageUrl;

  const AnalysisResultModel({
    required this.id,
    required this.imageId,
    required this.projectId,
    required this.userId,
    required this.constructionStage,
    required this.stageConfidence,
    required this.defects,
    required this.bestPractices,
    required this.overallAssessment,
    required this.analyzedAt,
    this.imageUrl,
  });

  factory AnalysisResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnalysisResultModel(
      id: doc.id,
      imageId: data['imageId'] as String? ?? '',
      projectId: data['projectId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      constructionStage: data['construction_stage'] as String? ?? '',
      stageConfidence: data['stage_confidence'] as String? ?? 'LOW',
      defects: (data['defects'] as List<dynamic>?)
              ?.map((d) => DefectModel.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
      bestPractices: List<String>.from(data['best_practices'] as List? ?? []),
      overallAssessment: data['overall_assessment'] as String? ?? 'WARNING',
      analyzedAt: (data['analyzedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  factory AnalysisResultModel.fromMap(Map<String, dynamic> map) {
    return AnalysisResultModel(
      id: map['id'] as String? ?? map['analysis_id'] as String? ?? '',
      imageId: map['imageId'] as String? ?? '',
      projectId: map['projectId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      constructionStage: map['construction_stage'] as String? ?? '',
      stageConfidence: map['stage_confidence'] as String? ?? 'LOW',
      defects: (map['defects'] as List<dynamic>?)
              ?.map((d) => DefectModel.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
      bestPractices: List<String>.from(map['best_practices'] as List? ?? []),
      overallAssessment: map['overall_assessment'] as String? ?? 'WARNING',
      analyzedAt: map['analyzedAt'] is Timestamp
          ? (map['analyzedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['analyzedAt'] as String? ?? '') ?? DateTime.now(),
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageId': imageId,
      'projectId': projectId,
      'userId': userId,
      'construction_stage': constructionStage,
      'stage_confidence': stageConfidence,
      'defects': defects.map((d) => d.toMap()).toList(),
      'best_practices': bestPractices,
      'overall_assessment': overallAssessment,
      'analyzedAt': Timestamp.fromDate(analyzedAt),
      'imageUrl': imageUrl,
    };
  }

  bool get isPass => overallAssessment == 'PASS';
  bool get isFail => overallAssessment == 'FAIL';
  bool get isWarning => overallAssessment == 'WARNING';

  int get highSeverityDefects =>
      defects.where((d) => d.confidence == 'HIGH').length;

  AnalysisResultModel copyWith({
    String? id,
    String? imageId,
    String? projectId,
    String? userId,
    String? constructionStage,
    String? stageConfidence,
    List<DefectModel>? defects,
    List<String>? bestPractices,
    String? overallAssessment,
    DateTime? analyzedAt,
    String? imageUrl,
  }) {
    return AnalysisResultModel(
      id: id ?? this.id,
      imageId: imageId ?? this.imageId,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      constructionStage: constructionStage ?? this.constructionStage,
      stageConfidence: stageConfidence ?? this.stageConfidence,
      defects: defects ?? this.defects,
      bestPractices: bestPractices ?? this.bestPractices,
      overallAssessment: overallAssessment ?? this.overallAssessment,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

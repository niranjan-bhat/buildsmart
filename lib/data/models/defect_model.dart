import 'package:cloud_firestore/cloud_firestore.dart';

class DefectModel {
  final String title;
  final String description;
  final String confidence;
  final List<String> rectificationSteps;
  final bool isRectified;
  final DateTime? rectifiedAt;

  const DefectModel({
    required this.title,
    required this.description,
    required this.confidence,
    required this.rectificationSteps,
    this.isRectified = false,
    this.rectifiedAt,
  });

  factory DefectModel.fromMap(Map<String, dynamic> map) {
    return DefectModel(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      confidence: map['confidence'] as String? ?? 'LOW',
      rectificationSteps:
          List<String>.from(map['rectification_steps'] as List? ?? []),
      isRectified: map['isRectified'] as bool? ?? false,
      rectifiedAt: map['rectifiedAt'] is Timestamp
          ? (map['rectifiedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'confidence': confidence,
      'rectification_steps': rectificationSteps,
      'isRectified': isRectified,
      'rectifiedAt':
          rectifiedAt != null ? Timestamp.fromDate(rectifiedAt!) : null,
    };
  }

  bool get isHighConfidence => confidence == 'HIGH';
  bool get isMediumConfidence => confidence == 'MEDIUM';
  bool get isLowConfidence => confidence == 'LOW';

  DefectModel copyWith({
    String? title,
    String? description,
    String? confidence,
    List<String>? rectificationSteps,
    bool? isRectified,
    DateTime? rectifiedAt,
    bool clearRectifiedAt = false,
  }) {
    return DefectModel(
      title: title ?? this.title,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      rectificationSteps: rectificationSteps ?? this.rectificationSteps,
      isRectified: isRectified ?? this.isRectified,
      rectifiedAt: clearRectifiedAt ? null : (rectifiedAt ?? this.rectifiedAt),
    );
  }

  @override
  String toString() =>
      'DefectModel(title: $title, confidence: $confidence, rectified: $isRectified)';
}

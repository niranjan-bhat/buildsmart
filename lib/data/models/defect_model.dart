class DefectModel {
  final String title;
  final String description;
  final String confidence;
  final List<String> rectificationSteps;

  const DefectModel({
    required this.title,
    required this.description,
    required this.confidence,
    required this.rectificationSteps,
  });

  factory DefectModel.fromMap(Map<String, dynamic> map) {
    return DefectModel(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      confidence: map['confidence'] as String? ?? 'LOW',
      rectificationSteps:
          List<String>.from(map['rectification_steps'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'confidence': confidence,
      'rectification_steps': rectificationSteps,
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
  }) {
    return DefectModel(
      title: title ?? this.title,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      rectificationSteps: rectificationSteps ?? this.rectificationSteps,
    );
  }

  @override
  String toString() =>
      'DefectModel(title: $title, confidence: $confidence)';
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  final String id;
  final String projectId;
  final String userId;
  final String storagePath;
  final String? downloadUrl;
  final String status; // pending | complete | error
  final DateTime uploadedAt;
  final DateTime? analyzedAt;
  final String? analysisResultId;
  final int fileSizeBytes;
  final String? errorMessage;
  final String language;

  const ImageModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.storagePath,
    this.downloadUrl,
    required this.status,
    required this.uploadedAt,
    this.analyzedAt,
    this.analysisResultId,
    this.fileSizeBytes = 0,
    this.errorMessage,
    this.language = 'English',
  });

  factory ImageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ImageModel(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      storagePath: data['storagePath'] as String? ?? '',
      downloadUrl: data['downloadUrl'] as String?,
      status: data['status'] as String? ?? 'pending',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      analyzedAt: (data['analyzedAt'] as Timestamp?)?.toDate(),
      analysisResultId: data['analysisResultId'] as String?,
      fileSizeBytes: data['fileSizeBytes'] as int? ?? 0,
      errorMessage: data['errorMessage'] as String?,
      language: data['language'] as String? ?? 'English',
    );
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      id: map['id'] as String? ?? '',
      projectId: map['projectId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      storagePath: map['storagePath'] as String? ?? '',
      downloadUrl: map['downloadUrl'] as String?,
      status: map['status'] as String? ?? 'pending',
      uploadedAt: map['uploadedAt'] is Timestamp
          ? (map['uploadedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['uploadedAt'] as String? ?? '') ?? DateTime.now(),
      analyzedAt: map['analyzedAt'] is Timestamp
          ? (map['analyzedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['analyzedAt'] as String? ?? ''),
      analysisResultId: map['analysisResultId'] as String?,
      fileSizeBytes: map['fileSizeBytes'] as int? ?? 0,
      errorMessage: map['errorMessage'] as String?,
      language: map['language'] as String? ?? 'English',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'userId': userId,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'status': status,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'analyzedAt': analyzedAt != null ? Timestamp.fromDate(analyzedAt!) : null,
      'analysisResultId': analysisResultId,
      'fileSizeBytes': fileSizeBytes,
      'errorMessage': errorMessage,
      'language': language,
    };
  }

  bool get isPending => status == 'pending';
  bool get isComplete => status == 'complete';
  bool get isError => status == 'error';

  ImageModel copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? storagePath,
    String? downloadUrl,
    String? status,
    DateTime? uploadedAt,
    DateTime? analyzedAt,
    String? analysisResultId,
    int? fileSizeBytes,
    String? errorMessage,
    String? language,
  }) {
    return ImageModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      status: status ?? this.status,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      analysisResultId: analysisResultId ?? this.analysisResultId,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
    );
  }
}

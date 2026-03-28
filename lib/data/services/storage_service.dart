import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<UploadResult> uploadProjectImage({
    required String userId,
    required String projectId,
    required File imageFile,
    void Function(double progress)? onProgress,
  }) async {
    final String fileName = '${_uuid.v4()}.jpg';
    final String storagePath =
        '${AppConstants.storageProjectImages}/$userId/$projectId/$fileName';

    final compressedXFile = await _compressImage(imageFile);
    final File fileToUpload =
        compressedXFile != null ? File(compressedXFile.path) : imageFile;

    final ref = _storage.ref().child(storagePath);
    final uploadTask = ref.putFile(
      fileToUpload,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'projectId': projectId,
          'originalFileName': imageFile.path.split('/').last,
        },
      ),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });
    }

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    final fileSizeBytes = await fileToUpload.length();

    if (compressedXFile != null && compressedXFile.path != imageFile.path) {
      try {
        await File(compressedXFile.path).delete();
      } catch (_) {}
    }

    return UploadResult(
      storagePath: storagePath,
      downloadUrl: downloadUrl,
      fileSizeBytes: fileSizeBytes,
    );
  }

  Future<XFile?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      return await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: AppConstants.imageQuality,
        minWidth: AppConstants.imageMaxWidth,
        minHeight: AppConstants.imageMaxHeight,
        format: CompressFormat.jpeg,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    final storagePath = 'avatars/$userId/avatar.jpg';
    final compressedXFile = await _compressImage(imageFile);
    final File fileToUpload =
        compressedXFile != null ? File(compressedXFile.path) : imageFile;

    final ref = _storage.ref().child(storagePath);
    await ref.putFile(
      fileToUpload,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final downloadUrl = await ref.getDownloadURL();

    if (compressedXFile != null && compressedXFile.path != imageFile.path) {
      try {
        await File(compressedXFile.path).delete();
      } catch (_) {}
    }

    return downloadUrl;
  }

  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).delete();
    } catch (_) {
      // File may not exist, ignore error
    }
  }

  Future<String> getDownloadUrl(String storagePath) async {
    return await _storage.ref().child(storagePath).getDownloadURL();
  }
}

class UploadResult {
  final String storagePath;
  final String downloadUrl;
  final int fileSizeBytes;

  const UploadResult({
    required this.storagePath,
    required this.downloadUrl,
    required this.fileSizeBytes,
  });
}

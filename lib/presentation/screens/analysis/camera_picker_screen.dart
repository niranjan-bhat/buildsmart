import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/image_model.dart';
import '../../../data/models/analysis_result_model.dart';
import '../../../data/repositories/image_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/image_provider.dart';

class CameraPickerScreen extends ConsumerStatefulWidget {
  final String projectId;

  const CameraPickerScreen({super.key, required this.projectId});

  @override
  ConsumerState<CameraPickerScreen> createState() =>
      _CameraPickerScreenState();
}

class _CameraPickerScreenState extends ConsumerState<CameraPickerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _uploadedImageId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uploadNotifierProvider.notifier).reset();
    });
  }

  Future<bool> _requestPermission(ImageSource source) async {
    final Permission permission;
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      // READ_MEDIA_IMAGES on API 33+, READ_EXTERNAL_STORAGE on older
      permission = Permission.photos;
    }

    final status = await permission.request();
    if (status.isGranted) return true;

    if (mounted) {
      if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Camera permission permanently denied. Enable it in Settings.'
                  : 'Photo library permission permanently denied. Enable it in Settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Camera permission is required to take a photo.'
                  : 'Photo library permission is required to select an image.',
            ),
          ),
        );
      }
    }
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    final granted = await _requestPermission(source);
    if (!granted) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _upload() async {
    if (_selectedImage == null) return;

    final imageModel = await ref
        .read(uploadNotifierProvider.notifier)
        .uploadImage(
          projectId: widget.projectId,
          imageFile: _selectedImage!,
        );

    if (imageModel != null) {
      setState(() => _uploadedImageId = imageModel.id);
      _listenForResult(imageModel.id);
    }
  }

  void _listenForResult(String imageId) {
    final userId = ref.read(authStateProvider).value?.uid ?? '';
    final repo = ref.read(imageRepositoryProvider);

    repo
        .getImageStream(userId, widget.projectId, imageId)
        .listen((imageModel) async {
      if (imageModel == null) return;

      if (imageModel.isComplete && imageModel.analysisResultId != null) {
        AnalysisResultModel? result;
        try {
          result = await repo.getAnalysisResult(
            userId,
            widget.projectId,
            imageModel.analysisResultId!,
          );
        } catch (_) {}

        ref
            .read(uploadNotifierProvider.notifier)
            .onAnalysisComplete(imageModel, result);

        if (mounted) {
          context.pushReplacement(
              '/projects/${widget.projectId}/analysis/$imageId');
        }
      } else if (imageModel.isError) {
        ref
            .read(uploadNotifierProvider.notifier)
            .onAnalysisComplete(imageModel, null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Analyse Image')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Take or upload a clear photo of the construction site. Our AI will identify the stage and detect any defects.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Image preview
            GestureDetector(
              onTap: uploadState.isUploading || uploadState.isAnalyzing
                  ? null
                  : () => _pickImage(ImageSource.gallery),
              child: Container(
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedImage != null
                        ? theme.colorScheme.primary
                        : Colors.grey.shade300,
                    width: _selectedImage != null ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _selectedImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover),
                            if (uploadState.isUploading ||
                                uploadState.isAnalyzing)
                              Container(
                                color: Colors.black54,
                                child: Center(
                                  child: _ProgressOverlay(
                                      uploadState: uploadState),
                                ),
                              ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to select an image',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Error message
            if (uploadState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        uploadState.hasNonConstructionError
                            ? 'This doesn\'t appear to be a construction site image. Please try a different photo.'
                            : uploadState.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            // Source buttons
            if (!uploadState.isUploading && !uploadState.isAnalyzing) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedImage != null ? _upload : null,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Analyse with AI'),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  uploadState.isUploading
                      ? 'Uploading image...'
                      : 'AI is analysing your image...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (uploadState.isAnalyzing) ...[
                const SizedBox(height: 8),
                Text(
                  'This usually takes 10-20 seconds',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressOverlay extends StatelessWidget {
  final UploadState uploadState;

  const _ProgressOverlay({required this.uploadState});

  @override
  Widget build(BuildContext context) {
    if (uploadState.isUploading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 5,
            percent: uploadState.uploadProgress,
            progressColor: Colors.white,
            backgroundColor: Colors.white24,
            center: Text(
              '${(uploadState.uploadProgress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Uploading...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'AI Analysing...',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

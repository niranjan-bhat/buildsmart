import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../data/models/analysis_result_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/image_provider.dart';

const int _maxImages = 5;

class CameraPickerScreen extends ConsumerStatefulWidget {
  final String projectId;

  const CameraPickerScreen({super.key, required this.projectId});

  @override
  ConsumerState<CameraPickerScreen> createState() =>
      _CameraPickerScreenState();
}

class _CameraPickerScreenState extends ConsumerState<CameraPickerScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uploadNotifierProvider.notifier).reset();
    });
  }

  Future<bool> _requestPermission(ImageSource source) async {
    final permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;
    final status = await permission.request();
    if (status.isGranted) return true;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.isPermanentlyDenied
                ? (source == ImageSource.camera
                    ? context.l10n.cameraPermissionPermanentlyDenied
                    : context.l10n.photoLibraryPermissionPermanentlyDenied)
                : (source == ImageSource.camera
                    ? context.l10n.cameraPermissionRequired
                    : context.l10n.photoLibraryPermissionRequired),
          ),
          action: status.isPermanentlyDenied
              ? SnackBarAction(label: context.l10n.openSettings, onPressed: openAppSettings)
              : null,
        ),
      );
    }
    return false;
  }

  Future<void> _pickFromCamera() async {
    if (_selectedImages.length >= _maxImages) return;
    final granted = await _requestPermission(ImageSource.camera);
    if (!granted) return;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );
      if (picked != null) {
        setState(() => _selectedImages.add(File(picked.path)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.failedCaptureImage(e.toString()))),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final remaining = _maxImages - _selectedImages.length;
    if (remaining <= 0) return;
    final granted = await _requestPermission(ImageSource.gallery);
    if (!granted) return;

    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );
      if (picked.isNotEmpty) {
        setState(() {
          final toAdd = picked.take(remaining).map((x) => File(x.path));
          _selectedImages.addAll(toAdd);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.failedPickImages(e.toString()))),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _upload() async {
    if (_selectedImages.isEmpty) return;

    final notifier = ref.read(uploadNotifierProvider.notifier);
    final language = ref.read(currentUserModelProvider).value?.preferredLanguage ?? 'English';

    if (_selectedImages.length == 1) {
      // Single image — existing flow: listen for result and navigate to it
      final imageModel = await notifier.uploadImage(
        projectId: widget.projectId,
        imageFile: _selectedImages.first,
        language: language,
      );
      if (imageModel != null) {
        _listenForSingleResult(imageModel.id);
      }
    } else {
      // Multi-image — upload all in parallel, then go to project detail
      final uploaded = await notifier.uploadImages(
        projectId: widget.projectId,
        imageFiles: _selectedImages,
        language: language,
      );
      if (uploaded.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.imagesUploading(uploaded.length))),
        );
        context.pop(); // Back to project detail; grid shows real-time status
      }
    }
  }

  void _listenForSingleResult(String imageId) {
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
    final isBusy = uploadState.isUploading || uploadState.isAnalyzing;
    final canAddMore =
        _selectedImages.length < _maxImages && !isBusy;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.analyseImages)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.l10n.imageSelectionHint(_maxImages),
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

            // Image selection area
            if (_selectedImages.isEmpty)
              _EmptyPickerArea(
                onCamera: _pickFromCamera,
                onGallery: _pickFromGallery,
                isBusy: isBusy,
              )
            else
              _SelectedImagesGrid(
                images: _selectedImages,
                isBusy: isBusy,
                uploadState: uploadState,
                onRemove: _removeImage,
              ),

            const SizedBox(height: 20),

            // Error
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
                        uploadState.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            // Action buttons
            if (!isBusy) ...[
              if (_selectedImages.isNotEmpty && canAddMore) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFromCamera,
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: Text(context.l10n.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: Text(
                          context.l10n.galleryLeft(_maxImages - _selectedImages.length),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _upload,
                    icon: const Icon(Icons.analytics_outlined),
                    label: Text(
                      _selectedImages.length == 1
                          ? context.l10n.analyseWithAI
                          : context.l10n.analyseWithAIMultiple(_selectedImages.length),
                    ),
                  ),
                ),
            ] else if (uploadState.isAnalyzing) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  context.l10n.aiAnalysing,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  context.l10n.usuallyTakes,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyPickerArea extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final bool isBusy;

  const _EmptyPickerArea({
    required this.onCamera,
    required this.onGallery,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: isBusy ? null : onGallery,
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(context.l10n.tapToSelectImages,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(context.l10n.upToMaxPhotos(_maxImages),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey.shade400)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : onCamera,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(context.l10n.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : onGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(context.l10n.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectedImagesGrid extends StatelessWidget {
  final List<File> images;
  final bool isBusy;
  final UploadState uploadState;
  final void Function(int) onRemove;

  const _SelectedImagesGrid({
    required this.images,
    required this.isBusy,
    required this.uploadState,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.imagesSelected(images.length),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            if (isBusy && uploadState.isMultiUpload)
              Text(
                context.l10n.uploadedCount(uploadState.completedUploads, uploadState.totalImages),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: images.length,
          itemBuilder: (ctx, i) {
            return _ImageThumb(
              file: images[i],
              index: i,
              isBusy: isBusy,
              isUploading: isBusy && i >= uploadState.completedUploads,
              onRemove: () => onRemove(i),
              uploadProgress: isBusy && uploadState.totalImages == 1
                  ? uploadState.uploadProgress
                  : null,
            );
          },
        ),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final File file;
  final int index;
  final bool isBusy;
  final bool isUploading;
  final VoidCallback onRemove;
  final double? uploadProgress;

  const _ImageThumb({
    required this.file,
    required this.index,
    required this.isBusy,
    required this.isUploading,
    required this.onRemove,
    this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(file, fit: BoxFit.cover),

          // Uploading overlay
          if (isBusy && isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: uploadProgress != null
                    ? CircularPercentIndicator(
                        radius: 22,
                        lineWidth: 3,
                        percent: uploadProgress!,
                        progressColor: Colors.white,
                        backgroundColor: Colors.white24,
                        center: Text(
                          '${(uploadProgress! * 100).toInt()}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    : const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      ),
              ),
            ),

          // Done overlay
          if (isBusy && !isUploading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Icon(Icons.check_circle, color: Colors.white, size: 28),
              ),
            ),

          // Remove button (only when not busy)
          if (!isBusy)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),

          // Image number badge
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

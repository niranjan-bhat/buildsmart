import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/models/image_model.dart';
import '../../../data/models/analysis_result_model.dart';
import '../../../data/repositories/image_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/image_provider.dart';
import '../../widgets/stage_badge.dart';
import '../../widgets/defect_card.dart';
import '../../widgets/loading_overlay.dart';

class AnalysisResultScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String imageId;

  const AnalysisResultScreen({
    super.key,
    required this.projectId,
    required this.imageId,
  });

  @override
  ConsumerState<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  ImageModel? _imageModel;
  AnalysisResultModel? _analysisResult;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = ref.read(authStateProvider).value?.uid ?? '';
    final repo = ref.read(imageRepositoryProvider);

    // Listen to image stream for real-time updates
    repo
        .getImageStream(userId, widget.projectId, widget.imageId)
        .listen((imageModel) async {
      if (!mounted) return;
      setState(() => _imageModel = imageModel);

      if (imageModel == null) {
        setState(() {
          _isLoading = false;
          _error = 'Image not found';
        });
        return;
      }

      if (imageModel.isComplete && imageModel.analysisResultId != null) {
        try {
          final result = await repo.getAnalysisResult(
            userId,
            widget.projectId,
            imageModel.analysisResultId!,
          );
          if (mounted) {
            setState(() {
              _analysisResult = result;
              _isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _error = 'Failed to load analysis result';
            });
          }
        }
      } else if (imageModel.isPending) {
        if (mounted) setState(() => _isLoading = true);
      } else if (imageModel.isError) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error =
                imageModel.errorMessage ?? 'Analysis failed. Please try again.';
          });
        }
      }
    });
  }

  Future<void> _exportPdf() async {
    if (_analysisResult == null || _imageModel == null) return;
    final result = _analysisResult!;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('BuildSmart Analysis Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Stage: ${result.constructionStage}'),
          pw.Text('Confidence: ${result.stageConfidence}'),
          pw.Text('Assessment: ${result.overallAssessment}'),
          pw.Text(
              'Date: ${DateFormat('dd MMM yyyy, HH:mm').format(result.analyzedAt)}'),
          pw.SizedBox(height: 24),
          if (result.defects.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Defects Found'),
            pw.SizedBox(height: 8),
            ...result.defects.asMap().entries.map((entry) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${entry.key + 1}. ${entry.value.title} [${entry.value.confidence}]',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(entry.value.description),
                    if (entry.value.rectificationSteps.isNotEmpty) ...[
                      pw.Text('Rectification:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ...entry.value.rectificationSteps.asMap().entries.map(
                            (s) => pw.Text('  ${s.key + 1}. ${s.value}'),
                          ),
                    ],
                    pw.SizedBox(height: 12),
                  ],
                )),
          ],
          if (result.bestPractices.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Best Practices'),
            pw.SizedBox(height: 8),
            ...result.bestPractices.map(
              (bp) => pw.Bullet(text: bp),
            ),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'BuildSmart_Analysis_${widget.imageId}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading && _analysisResult == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Result')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                _imageModel?.isPending ?? true
                    ? 'AI is analysing your image...'
                    : 'Loading results...',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This usually takes 10–20 seconds',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      final isNonConstruction =
          _error!.contains(AppConstants.nonConstructionImageError) ||
              _error!.toLowerCase().contains('non_construction');
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Result')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isNonConstruction
                      ? Icons.no_photography_outlined
                      : Icons.error_outline,
                  size: 64,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  isNonConstruction
                      ? 'Not a Construction Image'
                      : 'Analysis Failed',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  isNonConstruction
                      ? 'The uploaded image does not appear to be a construction site. Please try again with a relevant photo.'
                      : _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final result = _analysisResult!;
    final assessmentColor = _getAssessmentColor(result.overallAssessment);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            title: const Text('Analysis Result'),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Export PDF',
                onPressed: _exportPdf,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _imageModel?.downloadUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _imageModel!.downloadUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey.shade200),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assessment banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: assessmentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: assessmentColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          result.isPass
                              ? Icons.check_circle_outline
                              : result.isFail
                                  ? Icons.cancel_outlined
                                  : Icons.warning_amber_outlined,
                          color: assessmentColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.overallAssessment,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: assessmentColor,
                                ),
                              ),
                              Text(
                                result.isPass
                                    ? 'No critical issues found'
                                    : '${result.defects.length} issue${result.defects.length == 1 ? '' : 's'} detected',
                                style: TextStyle(
                                  color: assessmentColor.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM\nHH:mm').format(result.analyzedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: assessmentColor.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stage badge
                  Center(
                    child: StageBadge(
                      stageName: result.constructionStage,
                      confidence: result.stageConfidence,
                      large: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Defects section
                  if (result.defects.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          'Defects Found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${result.defects.length}',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...result.defects.asMap().entries.map(
                          (entry) => DefectCard(
                            defect: entry.value,
                            index: entry.key + 1,
                          ),
                        ),
                    const SizedBox(height: 24),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No defects detected! This stage looks good.',
                              style: TextStyle(color: Colors.green.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Best practices
                  if (result.bestPractices.isNotEmpty) ...[
                    Text(
                      'Best Practices',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: result.bestPractices
                            .map(
                              (bp) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        bp,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(height: 1.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Export button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _exportPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Export as PDF'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Back to Project'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAssessmentColor(String assessment) {
    switch (assessment.toUpperCase()) {
      case 'PASS':
        return Colors.green.shade700;
      case 'FAIL':
        return Colors.red.shade700;
      default:
        return Colors.orange.shade700;
    }
  }
}

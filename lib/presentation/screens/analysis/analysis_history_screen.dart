import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/analysis_result_model.dart';
import '../../../core/constants/construction_stages.dart';
import '../../providers/image_provider.dart';
import '../../widgets/analysis_card.dart';

class AnalysisHistoryScreen extends ConsumerStatefulWidget {
  final String projectId;

  const AnalysisHistoryScreen({super.key, required this.projectId});

  @override
  ConsumerState<AnalysisHistoryScreen> createState() =>
      _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState
    extends ConsumerState<AnalysisHistoryScreen> {
  String? _selectedStageFilter;
  String? _selectedAssessmentFilter;

  List<AnalysisResultModel> _applyFilters(
      List<AnalysisResultModel> results) {
    return results.where((r) {
      if (_selectedStageFilter != null &&
          r.constructionStage != _selectedStageFilter) {
        return false;
      }
      if (_selectedAssessmentFilter != null &&
          r.overallAssessment != _selectedAssessmentFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync =
        ref.watch(analysisResultsStreamProvider(widget.projectId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        actions: [
          if (_selectedStageFilter != null || _selectedAssessmentFilter != null)
            TextButton(
              onPressed: () => setState(() {
                _selectedStageFilter = null;
                _selectedAssessmentFilter = null;
              }),
              child: const Text('Clear'),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: resultsAsync.when(
        data: (results) {
          final filtered = _applyFilters(results);

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No analyses yet',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Upload images to start tracking your project',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No results match the filters'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedStageFilter = null;
                      _selectedAssessmentFilter = null;
                    }),
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Active filters chips
              if (_selectedStageFilter != null ||
                  _selectedAssessmentFilter != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      if (_selectedStageFilter != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(_selectedStageFilter!,
                                style: const TextStyle(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => setState(
                                () => _selectedStageFilter = null),
                          ),
                        ),
                      if (_selectedAssessmentFilter != null)
                        Chip(
                          label: Text(_selectedAssessmentFilter!,
                              style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => setState(
                              () => _selectedAssessmentFilter = null),
                        ),
                    ],
                  ),
                ),

              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final result = filtered[i];
                    return AnalysisCard(
                      result: result,
                      onTap: () => context.push(
                          '/projects/${widget.projectId}/analysis/${result.imageId}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Failed to load history: $e'),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scroll) => Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Filters',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedStageFilter = null;
                        _selectedAssessmentFilter = null;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text('Construction Stage',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ConstructionStages.stageNames.map((stage) {
                      final isSelected = _selectedStageFilter == stage;
                      return FilterChip(
                        label: Text(stage,
                            style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedStageFilter = val ? stage : null;
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Assessment',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['PASS', 'FAIL', 'WARNING'].map((assessment) {
                      final isSelected =
                          _selectedAssessmentFilter == assessment;
                      return FilterChip(
                        label: Text(assessment,
                            style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedAssessmentFilter =
                                val ? assessment : null;
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../data/models/analysis_result_model.dart';
import '../../core/constants/construction_stages.dart';

class AnalysisCard extends StatelessWidget {
  final AnalysisResultModel result;
  final VoidCallback? onTap;

  const AnalysisCard({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stage = ConstructionStages.getByName(result.constructionStage);
    final stageColor = stage?.color ?? theme.colorScheme.primary;
    final assessmentColor = _getAssessmentColor(result.overallAssessment);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: result.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: result.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image, size: 28, color: Colors.grey),
                          ),
                          errorWidget: (ctx, url, err) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image, size: 28, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image, size: 28, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                stage?.icon ?? Icons.construction,
                                size: 14,
                                color: stageColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  result.constructionStage,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: stageColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: assessmentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            result.overallAssessment,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: assessmentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${result.defects.length} defect${result.defects.length == 1 ? '' : 's'} found',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (result.highSeverityDefects > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${result.highSeverityDefects} HIGH',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, h:mm a').format(result.analyzedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
        ),
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

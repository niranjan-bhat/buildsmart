import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../data/models/project_model.dart';
import '../../core/constants/construction_stages.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stage = ConstructionStages.getByName(project.currentStage);
    final stageColor = stage?.color ?? theme.colorScheme.primary;
    final progress = project.progressPercentage;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: project.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: project.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => _buildPlaceholder(stageColor, stage),
                        errorWidget: (ctx, url, err) =>
                            _buildPlaceholder(stageColor, stage),
                      )
                    : _buildPlaceholder(stageColor, stage),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and stage
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    project.location.isNotEmpty
                                        ? project.location
                                        : 'Location not set',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Stage badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: stageColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: stageColor.withOpacity(0.25)),
                        ),
                        child: Text(
                          '${project.currentStageIndex + 1}/11',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: stageColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            project.currentStage,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: stageColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearPercentIndicator(
                        percent: progress,
                        lineHeight: 6,
                        backgroundColor: stageColor.withOpacity(0.12),
                        progressColor: stageColor,
                        barRadius: const Radius.circular(3),
                        padding: EdgeInsets.zero,
                        animation: true,
                        animationDuration: 600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stats row
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.analytics_outlined,
                        label: '${project.totalAnalyses} analyses',
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.warning_amber_outlined,
                        label: '${project.totalDefects} defects',
                        color: project.totalDefects > 0
                            ? Colors.orange
                            : Colors.green,
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('dd MMM').format(project.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color, dynamic stage) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Icon(
          stage?.icon ?? Icons.construction,
          size: 48,
          color: color.withOpacity(0.4),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/construction_stages.dart';

class StageBadge extends StatelessWidget {
  final String stageName;
  final String? confidence;
  final bool large;

  const StageBadge({
    super.key,
    required this.stageName,
    this.confidence,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final stage = ConstructionStages.getByName(stageName);
    final color = stage?.color ?? const Color(0xFF607D8B);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: large ? 16 : 10,
            vertical: large ? 10 : 6,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.12),
            borderRadius: BorderRadius.circular(large ? 12 : 8),
            border: Border.all(color: color.withValues(alpha:0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                stage?.icon ?? Icons.construction,
                size: large ? 22 : 16,
                color: color,
              ),
              SizedBox(width: large ? 10 : 6),
              Text(
                stageName,
                style: TextStyle(
                  fontSize: large ? 16 : 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        if (confidence != null) ...[
          const SizedBox(height: 6),
          _ConfidenceBadge(confidence: confidence!),
        ],
      ],
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final String confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (confidence.toUpperCase()) {
      case 'HIGH':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'MEDIUM':
        color = Colors.orange;
        icon = Icons.remove_circle_outline;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          '${confidence.toUpperCase()} CONFIDENCE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class StageProgressRing extends StatelessWidget {
  final String currentStage;
  final double size;

  const StageProgressRing({
    super.key,
    required this.currentStage,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final stageIndex = ConstructionStages.getIndexByName(currentStage);
    final progress = (stageIndex + 1) / ConstructionStages.stages.length;
    final stage = ConstructionStages.getByName(currentStage);
    final color = stage?.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${stageIndex + 1}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1.1,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'of 11',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

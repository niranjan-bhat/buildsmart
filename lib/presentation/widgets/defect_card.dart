import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/extensions/l10n_extension.dart';
import '../../data/models/defect_model.dart';

class DefectCard extends StatefulWidget {
  final DefectModel defect;
  final int index;
  final void Function(bool)? onRectifiedToggle;

  const DefectCard({
    super.key,
    required this.defect,
    required this.index,
    this.onRectifiedToggle,
  });

  @override
  State<DefectCard> createState() => _DefectCardState();
}

class _DefectCardState extends State<DefectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidenceColor = _getConfidenceColor(widget.defect.confidence);
    final isRectified = widget.defect.isRectified;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRectified
            ? Colors.green.shade50
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRectified
              ? Colors.green.shade200
              : confidenceColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _expanded,
          onExpansionChanged: (val) => setState(() => _expanded = val),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isRectified
                  ? Colors.green.withValues(alpha: 0.12)
                  : confidenceColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isRectified
                ? Icon(Icons.check, size: 18, color: Colors.green.shade700)
                : Text(
                    '${widget.index}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: confidenceColor,
                      fontSize: 14,
                    ),
                  ),
          ),
          title: Text(
            widget.defect.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              decoration: isRectified ? TextDecoration.lineThrough : null,
              color: isRectified
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                  : null,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isRectified
                      ? Colors.green.withValues(alpha: 0.1)
                      : confidenceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isRectified ? context.l10n.rectified : widget.defect.confidence,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isRectified
                        ? Colors.green.shade700
                        : confidenceColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (isRectified && widget.defect.rectifiedAt != null) ...[
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM').format(widget.defect.rectifiedAt!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    widget.defect.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (widget.defect.rectificationSteps.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.rectificationSteps,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...widget.defect.rectificationSteps.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (widget.onRectifiedToggle != null) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: isRectified
                          ? OutlinedButton.icon(
                              onPressed: () =>
                                  widget.onRectifiedToggle!(false),
                              icon: const Icon(Icons.undo, size: 16),
                              label: Text(context.l10n.markAsUnresolved),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange.shade700,
                                side: BorderSide(
                                    color: Colors.orange.shade300),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () =>
                                  widget.onRectifiedToggle!(true),
                              icon: const Icon(Icons.check_circle_outline,
                                  size: 16),
                              label: Text(context.l10n.markAsRectified),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(String confidence) {
    switch (confidence.toUpperCase()) {
      case 'HIGH':
        return Colors.red.shade700;
      case 'MEDIUM':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}

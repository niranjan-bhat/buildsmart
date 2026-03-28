import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/construction_stages.dart';
import '../../../data/models/checklist_model.dart';
import '../../providers/checklist_provider.dart';
import '../../providers/project_provider.dart';

class ChecklistScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ChecklistScreen({super.key, required this.projectId});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedStageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ConstructionStages.stages.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedStageIndex = _tabController.index);
        _loadChecklist(_tabController.index);
      }
    });
    _initCurrentStage();
    _loadChecklist(0);
  }

  void _initCurrentStage() {
    final projectAsync = ref.read(projectStreamProvider(widget.projectId));
    projectAsync.when(
      data: (project) {
        if (project != null) {
          final idx = project.currentStageIndex;
          _tabController.animateTo(idx);
          setState(() => _selectedStageIndex = idx);
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  void _loadChecklist(int stageIndex) {
    final stage = ConstructionStages.stages[stageIndex].name;
    ref.read(checklistNotifierProvider.notifier).loadChecklist(
          projectId: widget.projectId,
          stage: stage,
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checklistState = ref.watch(checklistNotifierProvider);
    final stage = ConstructionStages.stages[_selectedStageIndex];
    final checklist =
        checklistState.checklists['${widget.projectId}_${stage.name}'];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: ConstructionStages.stages
              .map((s) => Tab(
                    child: Text(
                      '${s.index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ))
              .toList(),
        ),
      ),
      body: Column(
        children: [
          // Stage header
          Container(
            padding: const EdgeInsets.all(16),
            color: stage.color.withOpacity(0.08),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: stage.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(stage.icon, color: stage.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: stage.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        stage.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (checklist != null)
                  CircularPercentIndicator(
                    radius: 26,
                    lineWidth: 4,
                    percent: checklist.completionRate.clamp(0.0, 1.0),
                    progressColor: stage.color,
                    backgroundColor: stage.color.withOpacity(0.15),
                    center: Text(
                      '${checklist.completedCount}/${checklist.totalCount}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: stage.color,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Checklist items
          Expanded(
            child: checklistState.isLoading && checklist == null
                ? const Center(child: CircularProgressIndicator())
                : checklist == null
                    ? _buildDefaultChecklist(stage.name)
                    : _buildChecklistItems(checklist, stage),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultChecklist(String stageName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChecklist(_selectedStageIndex);
    });
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildChecklistItems(ChecklistStageModel checklist, dynamic stage) {
    if (checklist.items.isEmpty) {
      return const Center(child: Text('No checklist items for this stage.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: checklist.items.length,
      itemBuilder: (ctx, i) {
        final item = checklist.items[i];
        return _ChecklistItemTile(
          item: item,
          stageColor: stage.color,
          onToggle: (val) {
            ref.read(checklistNotifierProvider.notifier).toggleItem(
                  projectId: widget.projectId,
                  stage: stage.name,
                  item: item,
                  isCompleted: val,
                );
          },
        );
      },
    );
  }
}

class _ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final Color stageColor;
  final void Function(bool) onToggle;

  const _ChecklistItemTile({
    required this.item,
    required this.stageColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: item.isCompleted
              ? stageColor.withOpacity(0.06)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: item.isCompleted
                ? stageColor.withOpacity(0.25)
                : theme.dividerTheme.color ?? Colors.grey.shade200,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 2),
          leading: GestureDetector(
            onTap: () => onToggle(!item.isCompleted),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: item.isCompleted
                    ? stageColor
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isCompleted
                      ? stageColor
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            item.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              decoration: item.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
              color: item.isCompleted
                  ? theme.colorScheme.onSurface.withOpacity(0.4)
                  : null,
            ),
          ),
          trailing: item.isCompleted
              ? Icon(Icons.verified_outlined,
                  size: 16, color: stageColor.withOpacity(0.6))
              : null,
          onTap: () => onToggle(!item.isCompleted),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/construction_stages.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../data/models/image_model.dart';
import '../../providers/project_provider.dart';
import '../../providers/image_provider.dart';
import '../../widgets/stage_badge.dart';
import '../../widgets/loading_overlay.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectStreamProvider(widget.projectId));
    final theme = Theme.of(context);

    return projectAsync.when(
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(context.l10n.projectNotFound)),
          );
        }

        final stage = ConstructionStages.getByName(project.currentStage);
        final stageColor = stage?.color ?? theme.colorScheme.primary;

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (ctx, innerBoxScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                floating: false,
                title: Text(project.name),
                flexibleSpace: FlexibleSpaceBar(
                  background: project.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: project.thumbnailUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: stageColor.withValues(alpha: 0.15),
                          child: Icon(
                            stage?.icon ?? Icons.construction,
                            size: 80,
                            color: stageColor.withValues(alpha: 0.3),
                          ),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    tooltip: context.l10n.analyseImage,
                    onPressed: () =>
                        context.push('/projects/${widget.projectId}/camera'),
                  ),
                ],
              ),
            ],
            body: Column(
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StageBadge(
                                  stageName: project.currentStage,
                                  large: false,
                                ),
                                const SizedBox(height: 8),
                                if (project.location.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          project.location,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Created ${DateFormat('dd MMM yyyy').format(project.createdAt)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StageProgressRing(
                            currentStage: project.currentStage,
                            size: 85,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Stage selector
                      _StageSelector(
                        currentIndex: project.currentStageIndex,
                        onStageSelected: (index) async {
                          final stageName =
                              ConstructionStages.stages[index].name;
                          await ref
                              .read(projectNotifierProvider.notifier)
                              .updateProjectStage(
                                  widget.projectId, stageName, index);
                        },
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context
                              .push('/projects/${widget.projectId}/history'),
                          icon: const Icon(Icons.history, size: 18),
                          label: Text(context.l10n.history),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context
                              .push('/projects/${widget.projectId}/checklist'),
                          icon: const Icon(Icons.checklist, size: 18),
                          label: Text(context.l10n.checklist),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab bar
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: context.l10n.recentTab),
                    Tab(text: context.l10n.stagesTab),
                    Tab(text: context.l10n.infoTab),
                  ],
                ),
                // Tab views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _RecentImagesTab(projectId: widget.projectId),
                      _TimelineTab(
                        currentIndex: project.currentStageIndex,
                        stageHistory: project.stageHistory,
                        projectCreatedAt: project.createdAt,
                      ),
                      _InfoTab(project: project),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                context.push('/projects/${widget.projectId}/camera'),
            tooltip: context.l10n.analyseImage,
            child: const Icon(Icons.add_a_photo_outlined),
          ),
        );
      },
      loading: () => Scaffold(
        body: FullScreenLoader(message: context.l10n.loadingProject),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StageSelector extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onStageSelected;

  const _StageSelector({
    required this.currentIndex,
    required this.onStageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ConstructionStages.stages.length,
        itemBuilder: (ctx, i) {
          final stage = ConstructionStages.stages[i];
          final isActive = i == currentIndex;
          final isDone = i < currentIndex;
          return GestureDetector(
            onTap: () => onStageSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? stage.color.withValues(alpha: 0.15)
                    : isDone
                        ? Colors.green.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? stage.color
                      : isDone
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.2),
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDone)
                    const Icon(Icons.check_circle,
                        size: 14, color: Colors.green)
                  else
                    Icon(stage.icon,
                        size: 14, color: isActive ? stage.color : Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    stage.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? stage.color
                          : isDone
                              ? Colors.green
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentImagesTab extends ConsumerWidget {
  final String projectId;

  const _RecentImagesTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(imagesStreamProvider(projectId));
    final theme = Theme.of(context);

    return imagesAsync.when(
      data: (images) {
        if (images.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera_outlined,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(context.l10n.noImagesTitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  context.l10n.noImagesDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: images.length,
          itemBuilder: (ctx, i) {
            final img = images[i];
            return _ImageTile(image: img, projectId: projectId);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ImageTile extends ConsumerWidget {
  final ImageModel image;
  final String projectId;

  const _ImageTile({required this.image, required this.projectId});

  void _showError(BuildContext context) {
    final reason = image.errorMessage ?? 'Unknown error';
    final isNonConstruction = reason.contains('NON_CONSTRUCTION');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline,
                      color: Colors.red.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.analysisFailed,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Text(
                isNonConstruction
                    ? context.l10n.nonConstructionError
                    : reason.replaceAll('NON_CONSTRUCTION_IMAGE', ''),
                style: TextStyle(color: Colors.red.shade800, height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.deleteImageHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreen(BuildContext context) {
    if (image.downloadUrl == null) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _FullScreenImageViewer(url: image.downloadUrl!),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (image.isComplete) {
          context.push('/projects/$projectId/analysis/${image.id}');
        } else if (image.isError) {
          _showError(context);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image.downloadUrl != null)
              CachedNetworkImage(
                imageUrl: image.downloadUrl!,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  child: Container(color: Colors.grey.shade200),
                ),
                errorWidget: (ctx, url, err) =>
                    Container(color: Colors.grey.shade200),
              )
            else
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade100,
                child: Container(color: Colors.grey.shade200),
              ),
            if (image.isPending)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (image.isError)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _showError(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            if (image.isComplete)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
            // Full-screen hint
            if (image.isComplete || image.downloadUrl != null)
              Positioned(
                top: 4,
                left: 4,
                child: GestureDetector(
                  onTap: () => _showFullScreen(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fullscreen,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String url;

  const _FullScreenImageViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (ctx, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (ctx, url, err) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final int currentIndex;
  final Map<String, DateTime> stageHistory;
  final DateTime projectCreatedAt;

  const _TimelineTab({
    required this.currentIndex,
    required this.stageHistory,
    required this.projectCreatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stages = ConstructionStages.stages;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: stages.length,
      itemBuilder: (ctx, i) {
        final stage = stages[i];
        final isDone = i < currentIndex;
        final isCurrent = i == currentIndex;
        final isUpcoming = i > currentIndex;
        final isLast = i == stages.length - 1;

        final startedAt = stageHistory[stage.name];
        String? dateLabel;
        if (startedAt != null) {
          dateLabel = DateFormat('dd MMM yyyy').format(startedAt);
        } else if (i == 0 && stageHistory.isEmpty) {
          dateLabel = DateFormat('dd MMM yyyy').format(projectCreatedAt);
        }

        // Duration spent in this stage
        String? durationLabel;
        if (isDone && startedAt != null) {
          // Find when next stage started
          final nextStage = stages[i + 1];
          final nextStarted = stageHistory[nextStage.name];
          if (nextStarted != null) {
            final days = nextStarted.difference(startedAt).inDays;
            durationLabel = days == 0
                ? context.l10n.sameDay
                : context.l10n.durationDays(days);
          }
        }

        final dotColor = isDone
            ? Colors.green
            : isCurrent
                ? stage.color
                : Colors.grey.shade300;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line + dot column
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    // Line above dot
                    if (i > 0)
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Container(
                            width: 2,
                            color: i <= currentIndex
                                ? Colors.green.withValues(alpha: 0.4)
                                : Colors.grey.shade200,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 12),
                    // Dot
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.green.withValues(alpha: 0.12)
                            : isCurrent
                                ? stage.color.withValues(alpha: 0.12)
                                : Colors.grey.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dotColor,
                          width: isCurrent ? 2 : 1.5,
                        ),
                      ),
                      child: Icon(
                        isDone
                            ? Icons.check
                            : isCurrent
                                ? stage.icon
                                : Icons.circle_outlined,
                        size: 14,
                        color: dotColor,
                      ),
                    ),
                    // Line below dot
                    if (!isLast)
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Container(
                            width: 2,
                            color: i < currentIndex
                                ? Colors.green.withValues(alpha: 0.4)
                                : Colors.grey.shade200,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? stage.color.withValues(alpha: 0.06)
                          : isDone
                              ? Colors.green.withValues(alpha: 0.03)
                              : theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? stage.color.withValues(alpha: 0.3)
                            : isDone
                                ? Colors.green.withValues(alpha: 0.15)
                                : (theme.dividerTheme.color ??
                                    Colors.grey.shade200),
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${i + 1}. ${stage.name}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isDone
                                      ? Colors.green.shade700
                                      : isCurrent
                                          ? stage.color
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: stage.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  context.l10n.inProgress,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: stage.color,
                                  ),
                                ),
                              )
                            else if (isDone)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  context.l10n.done,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (!isUpcoming) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (dateLabel != null) ...[
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 11,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  context.l10n.startedLabel(dateLabel),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                              if (durationLabel != null) ...[
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.timer_outlined,
                                  size: 11,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  durationLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        if (!isUpcoming) ...[
                          const SizedBox(height: 4),
                          Text(
                            stage.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoTab extends StatelessWidget {
  final dynamic project;

  const _InfoTab({required this.project});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow(label: 'Project Name', value: project.name),
        _InfoRow(
          label: context.l10n.locationLabel,
          value: project.location.isNotEmpty
              ? project.location
              : context.l10n.locationNotSet,
        ),
        _InfoRow(
          label: context.l10n.description,
          value: project.description.isNotEmpty
              ? project.description
              : context.l10n.noDescription,
        ),
        _InfoRow(
          label: context.l10n.createdLabel,
          value: DateFormat('dd MMMM yyyy').format(project.createdAt),
        ),
        _InfoRow(
          label: context.l10n.totalAnalyses,
          value: '${project.totalAnalyses}',
        ),
        _InfoRow(
          label: context.l10n.totalDefects,
          value: '${project.totalDefects}',
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(value, style: theme.textTheme.bodyMedium),
          const Divider(height: 20),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/current_activity_provider.dart';
import '../../widgets/activity/activity_card.dart';
import '../../widgets/activity/current_activity_banner.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/animated/fade_in_card.dart';
import '../../../data/models/timetable.dart';
import '../create_edit/create_edit_timetable_screen.dart';
import '../share/share_timetable_screen.dart';

/// Timetable detail screen showing activities in timeline view
/// Shows current activity banner if alerts are enabled
class TimetableDetailScreen extends StatefulWidget {
  final String timetableId;

  const TimetableDetailScreen({
    super.key,
    required this.timetableId,
  });

  @override
  State<TimetableDetailScreen> createState() => _TimetableDetailScreenState();
}

class _TimetableDetailScreenState extends State<TimetableDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Set this timetable as selected for current activity tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TimetableProvider>();
      final activityProvider = context.read<CurrentActivityProvider>();
      final timetable = provider.getTimetableById(widget.timetableId);
      if (timetable != null) {
        activityProvider.setSelectedTimetable(timetable);
      }
    });
  }

  @override
  void dispose() {
    // Clear selected timetable
    context.read<CurrentActivityProvider>().setSelectedTimetable(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, provider, _) {
        final timetable = provider.getTimetableById(widget.timetableId);

        if (timetable == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Timetable Not Found'),
            ),
            body: const Center(
              child: ErrorState(
                message: 'This timetable could not be found.',
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (timetable.emoji != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      timetable.emoji!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                Flexible(
                  child: Text(
                    timetable.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              // Share button (own timetables only)
              if (timetable.type == TimetableType.own)
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShareTimetableScreen(
                          timetableId: timetable.id,
                        ),
                      ),
                    );
                  },
                ),
              // Options menu
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptionsMenu(context, timetable),
              ),
            ],
          ),
          body: _buildBody(context, timetable),
          floatingActionButton: _buildFAB(context, timetable),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Timetable timetable) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<TimetableProvider>().loadAllTimetables();
      },
      child: CustomScrollView(
        slivers: [
          // Current activity banner (if alerts enabled)
          if (timetable.alertsEnabled)
            SliverToBoxAdapter(
              child: CurrentActivityBanner(
                timetableId: timetable.id,
              ),
            ),
          // Description (if exists)
          if (timetable.description?.isNotEmpty == true)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  timetable.description!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          // Stats section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildStatsSection(context, timetable),
            ),
          ),
          // Activities section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Schedule',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          // Activities timeline
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final activity = timetable.activities[index];
                final currentActivity = timetable.alertsEnabled
                    ? context.watch<CurrentActivityProvider>()
                        .getCurrentActivityFor(timetable.id)
                    : null;
                final isCurrent = currentActivity?.id == activity.id;
                final progress = isCurrent && timetable.alertsEnabled
                    ? context.watch<CurrentActivityProvider>()
                        .getProgressFor(timetable.id)
                    : 0.0;

                return FadeInCard(
                  delay: Duration(milliseconds: index * 50),
                  child: ActivityCard(
                    activity: activity,
                    isCurrent: isCurrent,
                    showProgress: isCurrent && timetable.alertsEnabled,
                    progress: progress,
                  ),
                );
              },
              childCount: timetable.activities.length,
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, Timetable timetable) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(
          icon: Icons.event_note,
          label: '${timetable.activities.length} activities',
          color: theme.colorScheme.primary,
        ),
        if (timetable.isActive)
          _StatChip(
            icon: Icons.star,
            label: 'Active',
            color: theme.colorScheme.secondary,
          ),
        if (timetable.alertsEnabled)
          _StatChip(
            icon: Icons.notifications_active,
            label: 'Alerts On',
            color: theme.colorScheme.tertiary,
          ),
        if (timetable.type != TimetableType.own)
          _StatChip(
            icon: Icons.cloud_download,
            label: timetable.type == TimetableType.imported
                ? 'Imported'
                : 'Template',
            color: theme.colorScheme.error,
          ),
      ],
    );
  }

  Widget? _buildFAB(BuildContext context, Timetable timetable) {
    if (timetable.type == TimetableType.own) {
      // Edit FAB for own timetables
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEditTimetableScreen(
                timetableId: timetable.id,
              ),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      );
    } else {
      // Duplicate FAB for imported/template timetables
      return FloatingActionButton.extended(
        onPressed: () => _duplicateTimetable(context, timetable),
        icon: const Icon(Icons.content_copy),
        label: const Text('Duplicate'),
      );
    }
  }

  Future<void> _duplicateTimetable(
    BuildContext context,
    Timetable timetable,
  ) async {
    final provider = context.read<TimetableProvider>();

    if (!provider.canCreateMore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You\'ve hit the max (5 tables). Delete one first 📊'),
        ),
      );
      return;
    }

    final duplicated = await provider.duplicateTimetable(timetable.id);
    if (duplicated != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Locked in! Timetable duplicated ✨'),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showOptionsMenu(BuildContext context, Timetable timetable) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _OptionsSheet(timetable: timetable),
    );
  }
}

/// Stats chip widget
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Options menu bottom sheet
class _OptionsSheet extends StatelessWidget {
  final Timetable timetable;

  const _OptionsSheet({required this.timetable});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TimetableProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Text(
                timetable.emoji ?? '📅',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  timetable.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          // Options
          if (timetable.type == TimetableType.own) ...[
            ListTile(
              leading: Icon(
                timetable.isActive ? Icons.star : Icons.star_border,
              ),
              title: Text(timetable.isActive ? 'Active' : 'Set as Active'),
              onTap: () async {
                if (!timetable.isActive) {
                  await provider.setActiveTimetable(timetable.id);
                }
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
          ListTile(
            leading: Icon(
              timetable.alertsEnabled
                  ? Icons.notifications_off
                  : Icons.notifications_active,
            ),
            title: Text(
              timetable.alertsEnabled ? 'Disable Alerts' : 'Enable Alerts',
            ),
            onTap: () async {
              await provider.toggleAlerts(
                timetable.id,
                !timetable.alertsEnabled,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
          if (timetable.type != TimetableType.own)
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Duplicate to My Tables'),
              onTap: () async {
                Navigator.pop(context);
                if (!provider.canCreateMore) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'You\'ve hit the max (5 tables). Delete one first 📊',
                      ),
                    ),
                  );
                  return;
                }
                final duplicated =
                    await provider.duplicateTimetable(timetable.id);
                if (duplicated != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Locked in! Timetable duplicated ✨'),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/sharing_provider.dart';
import '../../providers/current_activity_provider.dart';
import '../../widgets/timetable/timetable_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/animated/fade_in_card.dart';
import '../../../data/models/timetable.dart';
import '../detail/timetable_detail_screen.dart';
import '../create_edit/create_edit_timetable_screen.dart';
import '../import/import_timetable_screen.dart';

/// Home screen with tab bar for My Tables, Imported, Templates
/// Main navigation hub for the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final timetableProvider = context.read<TimetableProvider>();
    final sharingProvider = context.read<SharingProvider>();
    final activityProvider = context.read<CurrentActivityProvider>();

    // Load timetables
    await timetableProvider.loadAllTimetables();

    // Load templates
    await sharingProvider.loadTemplates();

    // Start tracking active timetables
    final alertEnabledTimetables = timetableProvider.alertEnabledTimetables;
    if (alertEnabledTimetables.isNotEmpty) {
      activityProvider.startTracking(alertEnabledTimetables);
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TimeTable',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'My Tables'),
            Tab(text: 'Imported'),
            Tab(text: 'Templates'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyTablesTab(onRefresh: _onRefresh),
          _ImportedTab(onRefresh: _onRefresh),
          _TemplatesTab(onRefresh: _onRefresh),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return Consumer<TimetableProvider>(
      builder: (context, provider, _) {
        final currentTab = _tabController.index;

        if (currentTab == 0) {
          // My Tables tab - show Create FAB if < 5
          if (provider.canCreateMore) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEditTimetableScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Table'),
            );
          }
        } else if (currentTab == 1) {
          // Imported tab - show Import FAB if < 5
          if (provider.canImportMore) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImportTimetableScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.cloud_download),
              label: const Text('Import'),
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// My Tables tab
class _MyTablesTab extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _MyTablesTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingIndicator.medium(
            text: 'Loading your vibes... 📅',
          );
        }

        if (provider.error != null) {
          return ErrorState(
            message: provider.error!,
            onRetry: onRefresh,
          );
        }

        final timetables = provider.ownTimetables;

        if (timetables.isEmpty) {
          return EmptyState(
            icon: Icons.schedule,
            title: 'No vibes here yet!',
            subtitle: 'Create your first schedule 🎯',
            action: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEditTimetableScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Table ✨'),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: timetables.length,
            itemBuilder: (context, index) {
              final timetable = timetables[index];
              return FadeInCard(
                delay: Duration(milliseconds: index * 100),
                child: TimetableCard(
                  timetable: timetable,
                  onTap: () => _onTimetableTap(context, timetable),
                  onOptions: () => _showOptionsMenu(context, timetable),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onTimetableTap(BuildContext context, Timetable timetable) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableDetailScreen(
          timetableId: timetable.id,
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, Timetable timetable) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _TimetableOptionsSheet(timetable: timetable),
    );
  }
}

/// Imported tab
class _ImportedTab extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _ImportedTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingIndicator.medium(
            text: 'Loading imported tables... 📥',
          );
        }

        if (provider.error != null) {
          return ErrorState(
            message: provider.error!,
            onRetry: onRefresh,
          );
        }

        final timetables = provider.importedTimetables;

        if (timetables.isEmpty) {
          return EmptyState(
            icon: Icons.cloud_download,
            title: 'Haven\'t imported any schedules yet',
            subtitle: 'Check out templates or import via share code! 👀',
            action: ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to import screen
              },
              icon: const Icon(Icons.cloud_download),
              label: const Text('Import Table'),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: timetables.length,
            itemBuilder: (context, index) {
              final timetable = timetables[index];
              return FadeInCard(
                delay: Duration(milliseconds: index * 100),
                child: TimetableCard(
                  timetable: timetable,
                  onTap: () => _onTimetableTap(context, timetable),
                  onOptions: () => _showOptionsMenu(context, timetable),
                  showActiveBadge: false, // Imported tables don't have active badge
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onTimetableTap(BuildContext context, Timetable timetable) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableDetailScreen(
          timetableId: timetable.id,
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, Timetable timetable) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _TimetableOptionsSheet(
        timetable: timetable,
        isImported: true,
      ),
    );
  }
}

/// Templates tab
class _TemplatesTab extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _TemplatesTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Consumer<SharingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingIndicator.medium(
            text: 'Loading templates... 📋',
          );
        }

        if (provider.error != null) {
          return ErrorState(
            message: provider.error!,
            onRetry: onRefresh,
          );
        }

        final templates = provider.templates;

        if (templates.isEmpty) {
          return const EmptyState(
            icon: Icons.library_books,
            title: 'No templates available',
            subtitle: 'Check back later for curated schedules!',
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return FadeInCard(
                delay: Duration(milliseconds: index * 100),
                child: TimetableCard(
                  timetable: template,
                  onTap: () => _onTemplateTap(context, template),
                  showActiveBadge: false,
                  showAlertStatus: false,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onTemplateTap(BuildContext context, Timetable template) {
    // Show preview and import option
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TemplatePreviewSheet(template: template),
    );
  }
}

/// Options menu bottom sheet for timetables
class _TimetableOptionsSheet extends StatelessWidget {
  final Timetable timetable;
  final bool isImported;

  const _TimetableOptionsSheet({
    required this.timetable,
    this.isImported = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timetableProvider = context.read<TimetableProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          if (!isImported) ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEditTimetableScreen(
                      timetableId: timetable.id,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                timetable.isActive ? Icons.star : Icons.star_border,
              ),
              title: Text(timetable.isActive ? 'Active' : 'Set as Active'),
              onTap: () async {
                if (!timetable.isActive) {
                  await timetableProvider.setActiveTimetable(timetable.id);
                }
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to share screen
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
              await timetableProvider.toggleAlerts(
                timetable.id,
                !timetable.alertsEnabled,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
          if (isImported)
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Duplicate to My Tables'),
              onTap: () async {
                await timetableProvider.duplicateTimetable(timetable.id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ListTile(
            leading: Icon(Icons.delete, color: theme.colorScheme.error),
            title: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () async {
              Navigator.pop(context);
              _confirmDelete(context, timetable);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Timetable timetable) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Timetable?'),
        content: Text(
          'Are you sure you want to delete "${timetable.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<TimetableProvider>();
      await provider.deleteTimetable(timetable.id);
    }
  }
}

/// Template preview bottom sheet
class _TemplatePreviewSheet extends StatelessWidget {
  final Timetable template;

  const _TemplatePreviewSheet({required this.template});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      template.emoji ?? '📅',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (template.description?.isNotEmpty == true)
                            Text(
                              template.description!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Activities preview
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: template.activities.length,
                  itemBuilder: (context, index) {
                    final activity = template.activities[index];
                    return ListTile(
                      leading: Text(
                        activity.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(activity.title),
                      subtitle: Text('${activity.time} - ${activity.endTime}'),
                    );
                  },
                ),
              ),
              // Import button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _importTemplate(context),
                    icon: const Icon(Icons.download),
                    label: const Text('Use This Template'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _importTemplate(BuildContext context) async {
    final provider = context.read<SharingProvider>();
    final timetableProvider = context.read<TimetableProvider>();

    if (!timetableProvider.canCreateMore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You\'ve hit the max (5 tables). Delete one first 📊'),
        ),
      );
      return;
    }

    Navigator.pop(context);

    final imported = await provider.importTemplate(template.id);
    if (imported != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Locked in! Template imported ✨'),
        ),
      );
    }
  }
}

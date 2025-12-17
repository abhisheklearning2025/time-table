import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/models/timetable.dart';
import '../../providers/sharing_provider.dart';
import '../../providers/timetable_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/app_button.dart';
import '../detail/timetable_detail_screen.dart';

/// Import timetable screen with three methods
/// 1. Enter share code
/// 2. Scan QR code
/// 3. Browse templates
class ImportTimetableScreen extends StatefulWidget {
  const ImportTimetableScreen({super.key});

  @override
  State<ImportTimetableScreen> createState() => _ImportTimetableScreenState();
}

class _ImportTimetableScreenState extends State<ImportTimetableScreen>
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Import Timetable',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Enter Code', icon: Icon(Icons.keyboard)),
            Tab(text: 'Scan QR', icon: Icon(Icons.qr_code_scanner)),
            Tab(text: 'Templates', icon: Icon(Icons.grid_view)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _EnterCodeTab(),
          _ScanQRTab(),
          _TemplatesTab(),
        ],
      ),
    );
  }
}

/// Tab 1: Enter share code manually
class _EnterCodeTab extends StatefulWidget {
  const _EnterCodeTab();

  @override
  State<_EnterCodeTab> createState() => _EnterCodeTabState();
}

class _EnterCodeTabState extends State<_EnterCodeTab> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isImporting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timetableProvider = context.watch<TimetableProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Enter Share Code',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Get the 6-character code from a friend',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Code input
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Share Code',
                hintText: 'ABC123',
                prefixIcon: const Icon(Icons.vpn_key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a share code';
                }
                if (value.trim().length != 6) {
                  return 'Code must be 6 characters';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),

          // Import button
          if (_isImporting)
            const LoadingIndicator.small(text: 'Importing...')
          else
            AppButton.primary(
              text: 'Import Timetable',
              onPressed: timetableProvider.canImportMore
                  ? _importFromCode
                  : null,
            ),

          // Limit warning
          if (!timetableProvider.canImportMore)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'ve hit the max (5 imported tables). Delete one first 📊',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _importFromCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isImporting = true;
    });

    try {
      final sharingProvider = context.read<SharingProvider>();
      final timetable = await sharingProvider.importTimetable(
        _codeController.text.trim().toUpperCase(),
      );

      if (!mounted) return;

      if (timetable != null) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Locked in! Timetable imported ✨'),
          ),
        );

        // Navigate to detail screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TimetableDetailScreen(
              timetableId: timetable.id,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('That code ain\'t it... Try again? 🤔'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }
}

/// Tab 2: Scan QR code
class _ScanQRTab extends StatefulWidget {
  const _ScanQRTab();

  @override
  State<_ScanQRTab> createState() => _ScanQRTabState();
}

class _ScanQRTabState extends State<_ScanQRTab> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timetableProvider = context.watch<TimetableProvider>();

    if (!timetableProvider.canImportMore) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'You\'ve hit the max (5 imported tables). Delete one first 📊',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Scanner view
        MobileScanner(
          controller: _scannerController,
          onDetect: _onQRDetected,
        ),

        // Overlay with instructions
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black.withValues(alpha: 0.7),
            child: Text(
              'Point at QR code to scan',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Processing indicator
        if (_isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: const Center(
              child: LoadingIndicator.medium(text: 'Importing...'),
            ),
          ),
      ],
    );
  }

  Future<void> _onQRDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Extract share code from URL or raw code
      final shareCode = _extractShareCode(code);
      if (shareCode == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid QR code format'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final sharingProvider = context.read<SharingProvider>();
      final timetable = await sharingProvider.importTimetable(shareCode);

      if (!mounted) return;

      if (timetable != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Locked in! Timetable imported ✨'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TimetableDetailScreen(
              timetableId: timetable.id,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('That code ain\'t it... Try again? 🤔'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String? _extractShareCode(String data) {
    // If it's a URL like https://timetable.app/t/ABC123
    if (data.contains('/t/')) {
      final parts = data.split('/t/');
      if (parts.length == 2) {
        return parts[1].trim().toUpperCase();
      }
    }

    // If it's just the code
    if (data.length == 6) {
      return data.trim().toUpperCase();
    }

    return null;
  }
}

/// Tab 3: Browse templates
class _TemplatesTab extends StatelessWidget {
  const _TemplatesTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sharingProvider = context.watch<SharingProvider>();
    final timetableProvider = context.watch<TimetableProvider>();

    final templates = sharingProvider.templates;

    if (sharingProvider.isLoading) {
      return const LoadingIndicator.medium(text: 'Loading templates...');
    }

    if (sharingProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load templates',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sharingProvider.error!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (templates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.grid_view,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No templates available',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for preset schedules! 🎯',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _TemplateCard(
          timetable: templates[index],
          canImport: timetableProvider.canImportMore,
        );
      },
    );
  }
}

/// Template card widget
class _TemplateCard extends StatelessWidget {
  final Timetable timetable;
  final bool canImport;

  const _TemplateCard({
    required this.timetable,
    required this.canImport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showTemplatePreview(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji
              Text(
                timetable.emoji ?? '📅',
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 6),
              // Name
              Flexible(
                child: Text(
                  timetable.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Description
              if (timetable.description?.isNotEmpty == true)
                Flexible(
                  child: Text(
                    timetable.description!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              // Activity count
              Row(
                children: [
                  Icon(
                    Icons.event_note,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${timetable.activities.length} activities',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTemplatePreview(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TemplatePreviewSheet(
        timetable: timetable,
        canImport: canImport,
      ),
    );

    if (result == true && context.mounted) {
      // Template was imported, navigate to detail screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TimetableDetailScreen(
            timetableId: timetable.id,
          ),
        ),
      );
    }
  }
}

/// Template preview bottom sheet
class _TemplatePreviewSheet extends StatefulWidget {
  final Timetable timetable;
  final bool canImport;

  const _TemplatePreviewSheet({
    required this.timetable,
    required this.canImport,
  });

  @override
  State<_TemplatePreviewSheet> createState() => _TemplatePreviewSheetState();
}

class _TemplatePreviewSheetState extends State<_TemplatePreviewSheet> {
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.timetable.emoji ?? '📅',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.timetable.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
              ),

              // Activities list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.timetable.activities.length,
                  itemBuilder: (context, index) {
                    final activity = widget.timetable.activities[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              activity.time,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            activity.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              activity.title,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Import button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: _isImporting
                    ? const LoadingIndicator.small(text: 'Importing...')
                    : AppButton.primary(
                        text: widget.canImport
                            ? 'Use This Template ✨'
                            : 'Can\'t Import (Max 5)',
                        onPressed: widget.canImport ? _importTemplate : null,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _importTemplate() async {
    setState(() {
      _isImporting = true;
    });

    try {
      final timetableProvider = context.read<TimetableProvider>();
      final imported = await timetableProvider.duplicateTimetable(
        widget.timetable.id,
      );

      if (!mounted) return;

      if (imported != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Locked in! Template imported ✨'),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to import template'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }
}

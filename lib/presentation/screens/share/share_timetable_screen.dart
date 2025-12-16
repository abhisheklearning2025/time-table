import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/sharing_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/app_button.dart';

/// Share timetable screen with QR code, share code, and link
/// Allows users to share their timetables via multiple methods
class ShareTimetableScreen extends StatefulWidget {
  final String timetableId;

  const ShareTimetableScreen({
    super.key,
    required this.timetableId,
  });

  @override
  State<ShareTimetableScreen> createState() => _ShareTimetableScreenState();
}

class _ShareTimetableScreenState extends State<ShareTimetableScreen> {
  bool _isExporting = false;
  String? _shareCode;
  String? _shareLink;
  String? _error;

  @override
  void initState() {
    super.initState();
    _exportTimetable();
  }

  Future<void> _exportTimetable() async {
    setState(() {
      _isExporting = true;
      _error = null;
    });

    try {
      final provider = context.read<SharingProvider>();
      final shareCode = await provider.exportTimetable(widget.timetableId);

      if (shareCode != null) {
        setState(() {
          _shareCode = shareCode;
          _shareLink = provider.generateShareLink(shareCode);
          _isExporting = false;
        });
      } else {
        setState(() {
          _error = 'Failed to export timetable. Try again?';
          _isExporting = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Share Your Vibe',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isExporting
          ? const LoadingIndicator.medium(text: 'Exporting timetable...')
          : _error != null
              ? _buildErrorState()
              : _buildShareContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Try Again',
              onPressed: _exportTimetable,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareContent() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header text
          Text(
            'Let others vibe with your schedule! 🔥',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Share via QR code, link, or code',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrImageView(
                data: _shareLink ?? '',
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: theme.colorScheme.primary,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Share code section
          _buildShareCodeSection(theme),
          const SizedBox(height: 16),

          // Share link section
          _buildShareLinkSection(theme),
          const SizedBox(height: 32),

          // Native share button
          AppButton.primary(
            text: 'Spread the Vibe 📤',
            onPressed: _shareViaSheet,
          ),
          const SizedBox(height: 16),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'How to share',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Scan QR code with camera\n'
                  '• Copy and send the share code\n'
                  '• Copy and send the share link\n'
                  '• Use the share button to send via WhatsApp, SMS, etc.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareCodeSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Code',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _shareCode ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyToClipboard(_shareCode ?? '', 'Share code'),
                tooltip: 'Copy code',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareLinkSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Link',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _shareLink ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyToClipboard(_shareLink ?? '', 'Share link'),
                tooltip: 'Copy link',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied! ✨'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareViaSheet() async {
    final text = 'Check out my timetable! 🔥\n\n'
        'Import it with code: $_shareCode\n'
        'Or visit: $_shareLink';

    await Share.share(
      text,
      subject: 'My TimeTable Schedule',
    );
  }
}

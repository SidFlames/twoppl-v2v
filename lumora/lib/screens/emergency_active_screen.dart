import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Emergency Active Screen — shown when an SOS has been triggered.
/// Displays live status of location sharing, audio/video recording,
/// and alert dispatch with real-time timers.
class EmergencyActiveScreen extends StatefulWidget {
  const EmergencyActiveScreen({super.key});

  @override
  State<EmergencyActiveScreen> createState() => _EmergencyActiveScreenState();
}

class _EmergencyActiveScreenState extends State<EmergencyActiveScreen>
    with TickerProviderStateMixin {
  // ── Material 3 color constants (matching project palette) ──────────────
  static const _primary = Color(0xFF003D9B);
  static const _primaryContainer = Color(0xFF0052CC);
  static const _secondary = Color(0xFF595F66);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _onSurfaceVariant = Color(0xFF434654);
  static const _surface = Color(0xFFFCF8FB);
  static const _surfaceContainerLow = Color(0xFFF6F3F5);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _outlineVariant = Color(0xFFC3C6D6);
  static const _error = Color(0xFFBA1A1A);
  static const _errorContainer = Color(0xFFFFDAD6);
  static const _tertiary = Color(0xFF8C0005);
  static const _tertiaryContainer = Color(0xFFB90009);

  // ── Animation controllers ──────────────────────────────────────────────
  late final AnimationController _sosPulseController;
  late final Animation<double> _sosPulseAnimation;
  late final AnimationController _statusBlinkController;

  // ── Timer state ────────────────────────────────────────────────────────
  Timer? _timer;
  int _audioSeconds = 0;
  int _videoSeconds = 0;
  int _contactsNotified = 3; // from the design: "Sharing with 3 contacts"
  int _alertsSent = 3;

  @override
  void initState() {
    super.initState();

    // SOS button pulse animation (2s infinite loop)
    _sosPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _sosPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sosPulseController,
        curve: const Cubic(0.4, 0.0, 0.6, 1.0),
      ),
    );

    // Status dot blink animation
    _statusBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Real-time timers (tick every second)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _audioSeconds++;
          _videoSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _sosPulseController.dispose();
    _statusBlinkController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return [
      hours.toString().padLeft(2, '0'),
      minutes.toString().padLeft(2, '0'),
      seconds.toString().padLeft(2, '0'),
    ].join(':');
  }

  Future<void> _onCallEmergencyServices() async {
    // TODO: Integrate with platform-specific emergency dialing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dialing emergency services…'),
        backgroundColor: _error,
      ),
    );
  }

  Future<void> _onCancelEmergency() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _error, size: 28),
            SizedBox(width: 8),
            Text('Cancel Emergency?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel the active emergency?\n\n'
          'Your guardians will be notified that the alert has been cancelled.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Active', style: TextStyle(color: _primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel Emergency'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Update Firestore emergency status
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final emergencies = await FirebaseFirestore.instance
              .collection('emergencies')
              .where('userId', isEqualTo: user.uid)
              .where('status', isEqualTo: 'active')
              .limit(1)
              .get();

          for (final doc in emergencies.docs) {
            await doc.reference.update({'status': 'cancelled'});
          }
        } catch (_) {
          // Silently handle — UI navigation is the priority
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _onSosTap() {
    // Re-broadcast emergency signal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency signal re-broadcast.'),
        backgroundColor: _error,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: const Row(
        children: [
          Icon(Icons.menu, color: _primary),
          SizedBox(width: 12),
          Text(
            'Lumora',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _primary,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: _primary),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        // Subtle emergency gradient background
        Positioned.fill(
          child: CustomPaint(
            painter: _EmergencyGradientPainter(),
          ),
        ),
        // Main content
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                children: [
                  _buildUrgencyHeader(),
                  const SizedBox(height: 32),
                  _buildSosButton(),
                  const SizedBox(height: 32),
                  _buildStatusCard(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencyHeader() {
    return Column(
      children: [
        Text(
          'EMERGENCY ACTIVE',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _error,
            letterSpacing: 2.0,
            height: 30 / 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Help is on the way. Your location is being tracked.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _secondary,
            height: 20 / 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSosButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_sosPulseAnimation, _statusBlinkController]),
      builder: (context, child) {
        final pulseValue = _sosPulseAnimation.value;

        // Outer ring 1
        final outerRing1Scale = 1.0 + pulseValue * 0.25;
        final outerRing1Opacity = 0.10 * (1.0 - pulseValue);

        // Outer ring 2
        final outerRing2Scale = 1.0 + pulseValue * 0.35;
        final outerRing2Opacity = 0.05 * (1.0 - pulseValue);

        // Shadow spread
        final shadowSpread = 0.4 * (1.0 - pulseValue);

        return SizedBox(
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring 2
              Transform.scale(
                scale: outerRing2Scale,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _error.withValues(alpha: outerRing2Opacity),
                  ),
                ),
              ),
              // Outer pulse ring 1
              Transform.scale(
                scale: outerRing1Scale,
                child: Container(
                  width: 256,
                  height: 256,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _error.withValues(alpha: outerRing1Opacity),
                  ),
                ),
              ),
              // SOS button
              GestureDetector(
                onTap: _onSosTap,
                child: AnimatedScale(
                  scale: 1.0 + pulseValue * 0.05,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _error,
                      boxShadow: [
                        BoxShadow(
                          color: _error.withValues(alpha: shadowSpread),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
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

  Widget _buildStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatusRow(
            icon: Icons.location_on,
            iconColor: _primary,
            iconBgColor: _primary.withValues(alpha: 0.1),
            title: 'Live Location Sharing',
            subtitle: 'Sharing with $_contactsNotified contacts',
            trailing: _buildLiveBadge(),
          ),
          _buildDivider(),
          _buildStatusRow(
            icon: Icons.mic,
            iconColor: _error,
            iconBgColor: _error.withValues(alpha: 0.1),
            title: 'Audio Recording',
            trailing: Text(
              _formatDuration(_audioSeconds),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _secondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _buildDivider(),
          _buildStatusRow(
            icon: Icons.videocam,
            iconColor: _error,
            iconBgColor: _error.withValues(alpha: 0.1),
            title: 'Recording Video',
            trailing: Text(
              _formatDuration(_videoSeconds),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _secondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _buildDivider(),
          _buildStatusRow(
            icon: Icons.send_and_archive,
            iconColor: _tertiary,
            iconBgColor: _tertiary.withValues(alpha: 0.1),
            title: 'Sending Alerts',
            trailing: Text(
              '$_alertsSent/$_alertsSent Sent',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(99),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Title + optional subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _onSurface,
                    height: 20 / 14,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _secondary,
                      height: 16 / 12,
                      letterSpacing: 0.02,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Trailing widget
          trailing,
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return AnimatedBuilder(
      animation: _statusBlinkController,
      builder: (context, _) {
        final opacity = 0.4 + (_statusBlinkController.value * 0.6);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withValues(alpha: opacity),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'LIVE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: Color(0xFFC3C6D6), thickness: 0.5),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.8),
        // Backdrop blur is not natively supported in Flutter without a package,
        // so we use a semi-transparent surface color instead.
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Call Emergency Services button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _onCallEmergencyServices,
                icon: const Icon(Icons.call, size: 20),
                label: const Text(
                  'Call Emergency Services',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cancel Emergency button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _onCancelEmergency,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _error,
                  side: const BorderSide(color: _error, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel Emergency',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the subtle radial emergency gradient background.
class _EmergencyGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const error = Color(0xFFBA1A1A);
    const primary = Color(0xFF003D9B);

    // Top-right: faint red radial
    final redPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.7, -0.7),
        radius: 0.6,
        colors: [
          error.withValues(alpha: 0.05),
          error.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), redPaint);

    // Bottom-left: faint blue radial
    final bluePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.7, 0.7),
        radius: 0.6,
        colors: [
          primary.withValues(alpha: 0.03),
          primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

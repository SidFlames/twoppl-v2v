import 'dart:async';
import 'package:flutter/material.dart';
import 'guardian_mode_dashboard_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  static const _primary = Color(0xFF003D9B);
  static const _primaryContainer = Color(0xFF0052CC);
  static const _secondary = Color(0xFF595F66);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _outlineVariant = Color(0xFFC3C6D6);
  static const _tertiary = Color(0xFF8C0005);
  static const _surface = Color(0xFFFCF8FB);
  static const _surfaceContainerHigh = Color(0xFFEAE7EA);
  static const _surfaceContainerHighest = Color(0xFFE4E2E4);

  double _sosProgress = 0.0;
  Timer? _sosTimer;
  DateTime? _holdStartTime;

  void _startSosHold() {
    setState(() {
      _sosProgress = 0.0;
      _holdStartTime = DateTime.now();
    });

    _sosTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_holdStartTime == null) return;
      final elapsed = DateTime.now().difference(_holdStartTime!).inMilliseconds;
      final pct = elapsed / 3000.0; // 3 seconds hold

      if (pct >= 1.0) {
        _triggerSos();
      } else {
        setState(() {
          _sosProgress = pct;
        });
      }
    });
  }

  void _resetSosHold() {
    _sosTimer?.cancel();
    setState(() {
      _sosProgress = 0.0;
      _holdStartTime = null;
    });
  }

  void _triggerSos() {
    _sosTimer?.cancel();
    setState(() {
      _sosProgress = 1.0;
      _holdStartTime = null;
    });

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('SOS Triggered', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          '🚨 EMERGENCY SOS ACTIVATED!\n\nYour trusted guardians have been notified of your location and environment audio feed.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Dismiss', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.menu, color: _primary),
            SizedBox(width: 12),
            Text(
              'SafeSphere',
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
          // Secure indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: _primaryContainer.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user, color: _primary, size: 12),
                SizedBox(width: 4),
                Text(
                  'SECURE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _primary),
            onPressed: () {},
          ),
          // User avatar
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _outlineVariant),
                color: _primary.withValues(alpha: 0.2),
              ),
              child: const Center(
                child: Text(
                  'J',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hello Greeting Section
                    const Text(
                      'Hello, John 👋',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Stay Safe Today',
                      style: TextStyle(
                        fontSize: 14,
                        color: _secondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile Strength Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _primary, width: 2),
                                  color: _primary.withValues(alpha: 0.1),
                                ),
                                child: const Center(
                                  child: Text(
                                    'J',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: _primary,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1A7A3C),
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 12),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Profile Strength',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _onSurface,
                                      ),
                                    ),
                                    Text(
                                      '80%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: const LinearProgressIndicator(
                                    value: 0.8,
                                    minHeight: 6,
                                    backgroundColor: _surfaceContainerHighest,
                                    valueColor: AlwaysStoppedAnimation<Color>(_primary),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'IDENTITY VERIFIED • 3 TRUSTED CONTACTS',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: _secondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Guardian Mode Card (Primary Blue Focus)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryContainer.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Row(
                                children: [
                                  Icon(Icons.security, color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'GUARDIAN MODE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Protection Running',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(99),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const GuardianModeDashboardScreen(),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Text(
                                  'Manage',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.chevron_right, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recent Journey Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.history, color: _primary, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Recent Journey',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _primaryContainer.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.home, color: _primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Home to Office',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Completed • 24 mins',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: _outlineVariant),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Emergency SOS Card
                    GestureDetector(
                      onTapDown: (_) => _startSosHold(),
                      onTapUp: (_) => _resetSosHold(),
                      onTapCancel: () => _resetSosHold(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        decoration: BoxDecoration(
                          color: _tertiary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _tertiary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: const Icon(Icons.emergency_share, color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '🚨 Emergency SOS',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Hold for 3 Seconds',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Progress indicator for SOS hold
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: _sosProgress,
                                minHeight: 6,
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live Tracking Map Card
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: _surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: const Size(double.infinity, 160),
                            painter: _LiveMapPainter(),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black54, Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 16,
                            right: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A7A3C),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'LIVE TRACKING',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Current Walk: Home',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  '8 min left',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: _outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.home, label: 'Home', active: true),
                  _buildNavItem(
                    icon: Icons.shield_outlined,
                    label: 'Safety',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GuardianModeDashboardScreen(),
                        ),
                      );
                    },
                  ),
                  _buildNavItem(icon: Icons.history, label: 'History'),
                  _buildNavItem(icon: Icons.person_outline, label: 'Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool active = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: active
            ? BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? _primary : _secondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _primary : _secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // Drawing city lines
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), paint);

    // Glowing point indicator
    final pointPaint = Paint()
      ..color = const Color(0xFF0052CC)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), 8, pointPaint);

    final glowPaint = Paint()
      ..color = const Color(0xFF0052CC).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), 16, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

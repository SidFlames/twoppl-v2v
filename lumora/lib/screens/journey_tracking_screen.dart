import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class JourneyTrackingScreen extends StatefulWidget {
  const JourneyTrackingScreen({super.key});

  @override
  State<JourneyTrackingScreen> createState() => _JourneyTrackingScreenState();
}

class _JourneyTrackingScreenState extends State<JourneyTrackingScreen>
    with TickerProviderStateMixin {
  // ── colours ──────────────────────────────────────────────────────────────
  static const _primary = Color(0xFF003D9B);
  static const _secondary = Color(0xFF595F66);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _outlineVariant = Color(0xFFC3C6D6);
  static const _surface = Color(0xFFFCF8FB);
  static const _success = Color(0xFF1A7A3C);
  static const _error = Color(0xFFBA1A1A);
  static const _errorContainer = Color(0xFF8C0005);

  // ── animation ─────────────────────────────────────────────────────────────
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // ── state ─────────────────────────────────────────────────────────────────
  String _statusMessage = ''; // '' = idle, 'safe' = confirmed, 'sos' = active


  // ── simulated live values ─────────────────────────────────────────────────
  int _etaMin = 18;
  double _distKm = 4.2;
  double _speedKmh = 45;
  late Timer _liveTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Tick live values every 3s to give a "live" feel
    _liveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _etaMin = math.max(0, _etaMin - 1);
        _distKm = math.max(0, double.parse((_distKm - 0.1).toStringAsFixed(1)));
        _speedKmh = 40 + (math.Random().nextDouble() * 12).roundToDouble();
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _liveTimer.cancel();
    super.dispose();
  }

  void _handleSafe() {
    setState(() {
      _statusMessage = 'safe';
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _statusMessage = '');
    });
  }

  void _handleNotSafe() {
    setState(() => _statusMessage = 'sos');
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  Widget _glass({required Widget child, EdgeInsets? padding, double? borderRadius}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── full-bleed map ──────────────────────────────────────────────
          Positioned.fill(child: _MapBackground()),

          // ── gradient fade at bottom ────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.92),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // ── top app bar ────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _glassIconBtn(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Journey Tracking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  _glassIconBtn(icon: Icons.notifications_outlined),
                ],
              ),
            ),
          ),

          // ── floating journey info card ─────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 68),
              child: _glass(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT JOURNEY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _secondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'To Home (SafeRoute AI)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Live badge
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) => Transform.scale(
                        scale: _pulseAnim.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: _primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primary,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: _primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── status overlay (safe / SOS) ────────────────────────────────
          if (_statusMessage.isNotEmpty)
            Positioned(
              left: 20, right: 20, bottom: 330,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _statusMessage == 'safe' ? _success : _error,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_statusMessage == 'safe' ? _success : _error).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _statusMessage == 'safe' ? Icons.check_circle_rounded : Icons.emergency_share_rounded,
                      color: _statusMessage == 'safe' ? _success : _error,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _statusMessage == 'safe'
                            ? 'Safe Status Confirmed — Contacts Notified'
                            : 'SOS ACTIVE — Emergency Contacts Alerted',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _statusMessage == 'safe' ? _success : _error,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── bottom bento dashboard ─────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 28, top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ETA & Distance row
                  _glass(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statCell(label: 'ETA', value: '$_etaMin', unit: 'min'),
                        Container(width: 1, height: 40, color: _outlineVariant),
                        _statCell(label: 'Distance', value: '$_distKm', unit: 'km'),
                        Container(width: 1, height: 40, color: _outlineVariant),
                        _statCell(label: 'Speed', value: '${_speedKmh.toInt()}', unit: 'km/h'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Status + Route row
                  Row(
                    children: [
                      Expanded(
                        child: _glass(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.route_outlined, size: 16, color: _secondary),
                                  const SizedBox(width: 6),
                                  Text('Status', style: TextStyle(fontSize: 11, color: _secondary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 16, color: _success),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'On Route',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _onSurface),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('DND Flyway', style: TextStyle(fontSize: 11, color: _secondary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _glass(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.shield_outlined, size: 16, color: _secondary),
                                  const SizedBox(width: 6),
                                  Text('Safety', style: TextStyle(fontSize: 11, color: _secondary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '96%',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text('Safe Route Score', style: TextStyle(fontSize: 11, color: _secondary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _actionBtn(
                          label: "I'm Safe",
                          icon: Icons.health_and_safety_rounded,
                          color: _primary,
                          onTap: _handleSafe,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionBtn(
                          label: 'Not Safe',
                          icon: Icons.warning_rounded,
                          color: _errorContainer,
                          onTap: _handleNotSafe,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassIconBtn({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _surface.withValues(alpha: 0.88),
          shape: BoxShape.circle,
          border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
          boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Icon(icon, color: _primary, size: 20),
      ),
    );
  }

  Widget _statCell({required String label, required String value, required String unit}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: _secondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(fontSize: 11, color: _secondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom map background painter ──────────────────────────────────────────
class _MapBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(),
      size: Size.infinite,
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE8EEF7);
    canvas.drawRect(Offset.zero & size, bg);

    // ── grid streets ─────────────────────────────────────────────────────
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final minorPaint = Paint()
      ..color = const Color(0xFFD8E2F0)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // horizontal streets
    for (int i = 1; i <= 8; i++) {
      final y = size.height * i / 9;
      final paint = i % 3 == 0 ? streetPaint : minorPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // vertical streets
    for (int i = 1; i <= 6; i++) {
      final x = size.width * i / 7;
      final paint = i % 2 == 0 ? streetPaint : minorPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // ── blocks (buildings) ────────────────────────────────────────────────
    final blockPaint = Paint()..color = const Color(0xFFCDD8EC);
    final rng = _SimpleRng(42);
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 4; c++) {
        final bx = size.width * (c + 0.3) / 4.5;
        final by = size.height * (r + 0.3) / 6;
        final bw = 30.0 + rng.next() * 40;
        final bh = 20.0 + rng.next() * 30;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx, by, bw, bh),
            const Radius.circular(4),
          ),
          blockPaint,
        );
      }
    }

    // ── blue route path ────────────────────────────────────────────────────
    final routePaint = Paint()
      ..color = const Color(0xFF003D9B)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final routeGlow = Paint()
      ..color = const Color(0xFF003D9B).withValues(alpha: 0.18)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.75)
      ..lineTo(size.width * 0.25, size.height * 0.45)
      ..lineTo(size.width * 0.57, size.height * 0.45)
      ..lineTo(size.width * 0.57, size.height * 0.25);

    canvas.drawPath(path, routeGlow);
    canvas.drawPath(path, routePaint);

    // ── destination pin ────────────────────────────────────────────────────
    final pinPaint = Paint()..color = const Color(0xFF8C0005);
    canvas.drawCircle(Offset(size.width * 0.57, size.height * 0.23), 8, pinPaint);
    canvas.drawCircle(
      Offset(size.width * 0.57, size.height * 0.23),
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // ── current location pulse ─────────────────────────────────────────────
    final outerPulse = Paint()
      ..color = const Color(0xFF003D9B).withValues(alpha: 0.15);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.75), 22, outerPulse);

    final midPulse = Paint()..color = const Color(0xFF003D9B).withValues(alpha: 0.25);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.75), 14, midPulse);

    final dot = Paint()..color = const Color(0xFF003D9B);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.75), 7, dot);
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.75),
      7,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// tiny deterministic pseudo-random helper (no dart:math Random seeding quirks)
class _SimpleRng {
  int _state;
  _SimpleRng(this._state);
  double next() {
    _state = (_state * 1664525 + 1013904223) & 0xFFFFFFFF;
    return (_state & 0xFFFF) / 0xFFFF;
  }
}

import 'package:flutter/material.dart';

class GuardianModeDashboardScreen extends StatefulWidget {
  const GuardianModeDashboardScreen({super.key});

  @override
  State<GuardianModeDashboardScreen> createState() => _GuardianModeDashboardScreenState();
}

class _GuardianModeDashboardScreenState extends State<GuardianModeDashboardScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF003D9B);
  static const _primaryContainer = Color(0xFFDAE2FF);
  static const _secondary = Color(0xFF595F66);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _onSurfaceVariant = Color(0xFF434654);
  static const _surface = Color(0xFFFCF8FB);
  static const _outlineVariant = Color(0xFFC3C6D6);
  static const _error = Color(0xFFBA1A1A);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _surfaceContainerLow = Color(0xFFF6F3F5);

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Guardian Mode',
          style: TextStyle(
            color: _primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _primary),
            onPressed: () {},
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
                    // Status Section
                    const SizedBox(height: 16),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulse rings
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _primary.withValues(alpha: 0.4 * (1.0 - _pulseAnimation.value)),
                                    width: 1 + (20 * _pulseAnimation.value),
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primaryContainer.withValues(alpha: 0.25),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shield_rounded,
                                color: _primary,
                                size: 48,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(99),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Protected',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Real-time surveillance active',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: _secondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bento Grid: Protection Score & Health Checklist
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Protection Score
                        Expanded(
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: _surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox.expand(
                                        child: CircularProgressIndicator(
                                          value: 1.0,
                                          strokeWidth: 8,
                                          backgroundColor: _outlineVariant.withValues(alpha: 0.2),
                                          valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                                        ),
                                      ),
                                      const Text(
                                        '100%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: _primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Protection Score',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Health Checklist
                        Expanded(
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: _surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Guardian Health',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: const [
                                      _ChecklistItem(title: 'Voice Ready'),
                                      SizedBox(height: 6),
                                      _ChecklistItem(title: 'GPS Ready'),
                                      SizedBox(height: 6),
                                      _ChecklistItem(title: 'Contacts Ready'),
                                      SizedBox(height: 6),
                                      _ChecklistItem(title: 'Permissions Ready'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Voice Protection Card
                    Container(
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.mic, color: _primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Voice Protection',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Listening',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '•',
                                      style: TextStyle(color: _outlineVariant, fontSize: 10),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Configured & Ready',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: _secondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SafeRoute AI Card
                    Container(
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Simple mockup city map area
                          Container(
                            height: 128,
                            color: const Color(0xFFE3F2FD),
                            child: Stack(
                              children: [
                                // Drawing a soft pathway mock grid
                                CustomPaint(
                                  size: const Size(double.infinity, 128),
                                  painter: _MapGridPainter(),
                                ),
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(color: _primary.withValues(alpha: 0.2)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.location_on, color: _primary, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'Mission District',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SafeRoute AI',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Current Journey Active',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: const [
                                    Text(
                                      '94%',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _primary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Safety Score',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Trusted Contacts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trusted Contacts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '3 Contacts linked',
                              style: TextStyle(fontSize: 12, color: _secondary),
                            ),
                          ],
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: _surfaceContainerLow,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Manage',
                            style: TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Stacked avatar rings
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: Stack(
                            children: [
                              _buildAvatar(index: 0, color: Colors.blueGrey),
                              Positioned(left: 24, child: _buildAvatar(index: 1, color: Colors.indigo)),
                              Positioned(left: 48, child: _buildAvatar(index: 2, color: Colors.teal)),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _primaryContainer.withValues(alpha: 0.25),
                            border: Border.all(color: _primary.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.add, color: _primary, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Recent Activity Section
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          _buildActivityTile(
                            icon: Icons.explore_outlined,
                            title: 'Route change detected',
                            subtitle: '12:45 PM • Handled by AI',
                          ),
                          const Divider(height: 1, indent: 56),
                          Opacity(
                            opacity: 0.6,
                            child: _buildActivityTile(
                              icon: Icons.mic_none_outlined,
                              title: 'Environment check: Silent',
                              subtitle: '11:30 AM • Normal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Area
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  border: Border(
                    top: BorderSide(
                      color: _outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _error,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: _error.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stop_circle, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Turn Protection Off',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar({required int index, required Color color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: _surface, width: 2),
      ),
      child: Center(
        child: Text(
          'G${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _secondary, size: 20),
          ),
          const SizedBox(width: 16),
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF003D9B), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF434654),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw some city grid streets
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);

    // Draw glowing primary path line
    final pathPaint = Paint()
      ..color = const Color(0xFF003D9B)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.3, size.height)
      ..lineTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.3);

    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

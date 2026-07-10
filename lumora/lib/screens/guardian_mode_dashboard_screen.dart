import 'package:flutter/material.dart';

class GuardianModeDashboardScreen extends StatefulWidget {
  const GuardianModeDashboardScreen({super.key, this.initialActive = true});
  final bool initialActive;

  @override
  State<GuardianModeDashboardScreen> createState() => _GuardianModeDashboardScreenState();
}

class _GuardianModeDashboardScreenState extends State<GuardianModeDashboardScreen>
    with TickerProviderStateMixin {
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
  static const _success = Color(0xFF006D32);

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _toggleController;
  late final Animation<double> _toggleAnimation;

  bool _isGuardianModeActive = true;

  @override
  void initState() {
    super.initState();
    _isGuardianModeActive = widget.initialActive;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    if (_isGuardianModeActive) {
      _pulseController.repeat();
    }

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _toggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _toggleAnimation = CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOut,
    );

    _toggleController.value = _isGuardianModeActive ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _toggleController.dispose();
    super.dispose();
  }

  void _toggleGuardianMode() {
    setState(() {
      _isGuardianModeActive = !_isGuardianModeActive;
      if (_isGuardianModeActive) {
        _toggleController.forward();
        _pulseController.repeat();
      } else {
        _toggleController.reverse();
        _pulseController.stop();
      }
    });
    // Debug: print state change
    debugPrint('Guardian Mode toggled to: $_isGuardianModeActive');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_isGuardianModeActive);
      },
      child: Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _primary),
          onPressed: () => Navigator.of(context).pop(_isGuardianModeActive),
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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {}, // Consume taps to prevent propagation
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
                              if (!_isGuardianModeActive) return const SizedBox.shrink();
                              return Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _success.withValues(alpha: 0.4 * (1.0 - _pulseAnimation.value)),
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
                              color: (_isGuardianModeActive ? _success : _error).withValues(alpha: 0.15),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.shield_rounded,
                                color: _isGuardianModeActive ? _success : _error,
                                size: 48,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isGuardianModeActive ? _success : _outlineVariant,
                                borderRadius: BorderRadius.circular(99),
                                boxShadow: _isGuardianModeActive
                                    ? [
                                        BoxShadow(
                                          color: _success.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                _isGuardianModeActive ? 'ACTIVE' : 'INACTIVE',
                                style: TextStyle(
                                  color: _isGuardianModeActive ? Colors.white : _onSurfaceVariant,
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

                    // Guardian Mode Toggle Switch
                    AnimatedBuilder(
                      animation: _toggleAnimation,
                      builder: (context, child) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _toggleGuardianMode,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 80,
                            height: 44,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: _isGuardianModeActive
                                  ? _success
                                  : _outlineVariant.withValues(alpha: 0.5),
                              boxShadow: _isGuardianModeActive
                                  ? [
                                      BoxShadow(
                                        color: _success.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background labels
                                Positioned(
                                  left: 12,
                                  child: Opacity(
                                    opacity: _isGuardianModeActive ? 0.0 : 1.0,
                                    child: const Text(
                                      'OFF',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  child: Opacity(
                                    opacity: _isGuardianModeActive ? 1.0 : 0.0,
                                    child: const Text(
                                      'ON',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                // Thumb
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  alignment: _isGuardianModeActive
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _isGuardianModeActive
                                            ? Icons.shield_rounded
                                            : Icons.shield_outlined,
                                        color: _isGuardianModeActive ? _success : _secondary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    Text(
                      _isGuardianModeActive ? 'Protected' : 'Unprotected',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isGuardianModeActive ? 'Real-time surveillance active' : 'Real-time surveillance inactive',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                            height: 170,
                            decoration: BoxDecoration(
                              color: _surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox.expand(
                                        child: CircularProgressIndicator(
                                          value: 1.0,
                                          strokeWidth: 7,
                                          backgroundColor: _outlineVariant.withValues(alpha: 0.2),
                                          valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                                        ),
                                      ),
                                      const Text(
                                        '100%',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: _primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Protection Score',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Health Checklist
                        Expanded(
                          child: Container(
                            height: 170,
                            decoration: BoxDecoration(
                              color: _surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Guardian Health',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const _ChecklistItem(title: 'Voice Ready'),
                                const SizedBox(height: 4),
                                const _ChecklistItem(title: 'GPS Ready'),
                                const SizedBox(height: 4),
                                const _ChecklistItem(title: 'Contacts Ready'),
                                const SizedBox(height: 4),
                                const _ChecklistItem(title: 'Permissions Ready'),
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
                                    Flexible(
                                      child: Text(
                                        'Configured & Ready',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _secondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isGuardianModeActive ? _error : _success,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: (_isGuardianModeActive ? _error : _success).withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _toggleGuardianMode,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isGuardianModeActive ? Icons.stop_circle : Icons.shield_rounded,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isGuardianModeActive ? 'Turn Protection Off' : 'Turn Protection On',
                            style: const TextStyle(
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
            ),
          ],
        ),
      ),     // GestureDetector
        ),     // SafeArea (body:)
      ),     // Scaffold (child: of PopScope)
    );       // PopScope
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
        const Icon(Icons.check_circle, color: Color(0xFF003D9B), size: 14),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF434654),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
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

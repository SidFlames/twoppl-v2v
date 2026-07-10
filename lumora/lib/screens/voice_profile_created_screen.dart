import 'package:flutter/material.dart';
import 'main_dashboard_screen.dart';

class VoiceProfileCreatedScreen extends StatefulWidget {
  const VoiceProfileCreatedScreen({super.key, this.secretPhrase = 'Blue Umbrella'});
  final String secretPhrase;

  @override
  State<VoiceProfileCreatedScreen> createState() => _VoiceProfileCreatedScreenState();
}

class _VoiceProfileCreatedScreenState extends State<VoiceProfileCreatedScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF003D9B);
  static const _secondary = Color(0xFF595F66);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _surface = Color(0xFFFCF8FB);
  static const _outlineVariant = Color(0xFFC3C6D6);
  static const _green = Color(0xFF1A7A3C);

  late final AnimationController _checkController;
  late final Animation<double> _checkScale;
  late final Animation<double> _checkOpacity;

  // Static bar heights for the vocal signature chart
  final List<double> _barHeights = [0.35, 0.55, 0.45, 0.80, 0.60, 0.40, 0.70, 0.50, 0.65, 0.45];

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScale = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);
    _checkOpacity = CurvedAnimation(parent: _checkController, curve: Curves.easeIn);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _checkController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'SafeSphere',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _primary,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: _secondary),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Animated check circle
              AnimatedBuilder(
                animation: _checkController,
                builder: (context, child) => Transform.scale(
                  scale: _checkScale.value,
                  child: Opacity(
                    opacity: _checkOpacity.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primary,
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.35),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Voice Profile Created!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _onSurface,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your voice is secured and enrolled successfully. SafeSphere is now ready to recognize your unique voice pattern.',
                style: TextStyle(fontSize: 14, color: _secondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Secret phrase card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _outlineVariant.withValues(alpha: 0.6)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'YOUR SECRET PHRASE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _secondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.mic_outlined, color: _secondary.withValues(alpha: 0.5), size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '"${widget.secretPhrase}"',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _primary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: _green.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, color: _green, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'VERIFIED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _green,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatItem(label: 'Match Accuracy', value: '99.8%'),
                        const SizedBox(width: 24),
                        _StatItem(label: 'Security Level', value: 'Tier 3 (Biometric)'),
                        const Spacer(),
                        Icon(Icons.info_outline, color: _secondary.withValues(alpha: 0.5), size: 18),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Vocal Signature Mapping chart
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _outlineVariant.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vocal Signature Mapping',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 70,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _barHeights.asMap().entries.map((e) {
                          final isActive = e.key == 3 || e.key == 6 || e.key == 9;
                          return Container(
                            width: 20,
                            height: 70 * e.value,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _primary
                                  : _primary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // AES enrolled badge (Subtle Fine Print)
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, color: _secondary, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Voice profile secured with 256-bit AES encryption',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _secondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Go to Dashboard button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const MainDashboardScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Go to Dashboard',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Manage Voice Profiles
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mic_none, size: 15, color: _secondary),
                label: const Text(
                  'Manage Voice Profiles',
                  style: TextStyle(fontSize: 13, color: _secondary, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 16),

              // Footer
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _green,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'System Secure • Connection Encrypted',
                    style: TextStyle(fontSize: 11, color: _secondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Support', style: TextStyle(fontSize: 12, color: _secondary)),
                  ),
                  const Text('  |  ', style: TextStyle(color: _outlineVariant)),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Privacy Policy', style: TextStyle(fontSize: 12, color: _secondary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF595F66))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1B1B1D))),
      ],
    );
  }
}

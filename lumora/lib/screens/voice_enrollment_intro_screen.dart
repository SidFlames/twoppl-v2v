import 'package:flutter/material.dart';
import 'recording_voiceprint_screen.dart';

class VoiceEnrollmentIntroScreen extends StatefulWidget {
  const VoiceEnrollmentIntroScreen({super.key});

  @override
  State<VoiceEnrollmentIntroScreen> createState() =>
      _VoiceEnrollmentIntroScreenState();
}

class _VoiceEnrollmentIntroScreenState
    extends State<VoiceEnrollmentIntroScreen>
    with TickerProviderStateMixin {
  static const _primary = Color(0xFF003D9B);
  static const _primaryContainer = Color(0xFF0052CC);
  static const _secondary = Color(0xFF595F66);
  static const _surface = Color(0xFFFCF8FB);
  static const _onSurface = Color(0xFF1B1B1D);

  late final AnimationController _pulseOuter;
  late final AnimationController _pulseInner;

  @override
  void initState() {
    super.initState();
    _pulseOuter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseInner = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseOuter.dispose();
    _pulseInner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _primary),
        ),
        title: const Text(
          'SafeSphere',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _primary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // Hero section
              const Text(
                'Voice Enrollment',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your voice profile for hands-free emergency activation.',
                style: TextStyle(
                  fontSize: 14,
                  color: _secondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Animated mic centerpiece
              SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing ring
                    AnimatedBuilder(
                      animation: _pulseOuter,
                      builder: (context, child) {
                        final scale = 0.9 + (_pulseOuter.value * 0.2);
                        final opacity = 0.4 + (_pulseOuter.value * 0.4);
                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _primaryContainer.withValues(alpha: 0.10),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Inner pulsing ring
                    AnimatedBuilder(
                      animation: _pulseInner,
                      builder: (context, child) {
                        final opacity = 0.15 + (_pulseInner.value * 0.25);
                        return Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 165,
                            height: 165,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primaryContainer.withValues(alpha: 0.20),
                            ),
                          ),
                        );
                      },
                    ),
                    // Mic button
                    Container(
                      width: 110,
                      height: 110,
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
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Instruction cards
              _InstructionCard(
                icon: Icons.campaign,
                title: 'Speak clearly',
                subtitle:
                    'You will be asked to repeat a secret phrase 3 times in a quiet environment.',
              ),
              const SizedBox(height: 12),
              _InstructionCard(
                icon: Icons.verified_user_outlined,
                title: 'Secure Voiceprint',
                subtitle:
                    'We secure your voice profile locally to ensure only you can trigger SOS alerts.',
              ),
              const SizedBox(height: 12),
              _InstructionCard(
                icon: Icons.help_outline,
                title: 'Identity Verification',
                subtitle:
                    'This helps our AI distinguish your voice from background noise or other people.',
              ),
              const SizedBox(height: 28),

              // Step progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepDot(number: 1, active: true),
                  _StepLine(),
                  _StepDot(number: 2, active: false),
                  _StepLine(),
                  _StepDot(number: 3, active: false),
                ],
              ),
              const SizedBox(height: 28),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RecordingVoiceprintScreen(phrase: 'Blue Umbrella'),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Takes less than 1 minute',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF737685),
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC3C6D6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF003D9B).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF003D9B), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1B1D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF595F66),
                    height: 1.4,
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

class _StepDot extends StatelessWidget {
  const _StepDot({required this.number, required this.active});
  final int number;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFF003D9B) : const Color(0xFFEAE7EA),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF434654),
          ),
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 2,
      color: const Color(0xFFC3C6D6),
    );
  }
}

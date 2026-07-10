import 'package:flutter/material.dart';
import 'secret_phrase_setup_screen.dart';

class VoiceEnrollmentIntroScreen extends StatefulWidget {
  const VoiceEnrollmentIntroScreen({super.key});

  @override
  State<VoiceEnrollmentIntroScreen> createState() => _VoiceEnrollmentIntroScreenState();
}

class _VoiceEnrollmentIntroScreenState extends State<VoiceEnrollmentIntroScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF0C56D0);
  static const _surface = Color(0xFFFCF8FB);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _secondary = Color(0xFF595F66);
  static const _border = Color(0xFFC3C6D6);

  late AnimationController _pulseController;
  bool _isInitializing = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_isInitialized) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SecretPhraseSetupScreen(),
        ),
      );
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    // Simulate microphone permission/initialization logic
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _isInitialized = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone access verified.'),
          backgroundColor: _primary,
        ),
      );
    });
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
          'SafeSphere',
          style: TextStyle(
            color: _primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    // Hero Section
                    const Text(
                      'Voice Enrollment',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your voice profile for hands-free emergency activation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: _secondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Visualizer / Microphone Centerpiece
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer animated ring
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 140 + (40 * _pulseController.value),
                                height: 140 + (40 * _pulseController.value),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primary.withValues(alpha: 0.1 * (1 - _pulseController.value)),
                                ),
                              );
                            },
                          ),
                          // Inner animated ring
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primary.withValues(alpha: 0.1),
                            ),
                          ),
                          // Mic Button
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primary,
                              boxShadow: [
                                BoxShadow(
                                  color: _primary.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bento cards
                    _buildInfoCard(
                      icon: Icons.campaign_outlined,
                      title: 'Speak clearly',
                      description: 'You will be asked to repeat a secret phrase 3 times in a quiet environment.',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.verified_user_outlined,
                      title: 'Secure Voiceprint',
                      description: 'We secure your voice profile locally to ensure only you can trigger SOS alerts.',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.help_outline_rounded,
                      title: 'Identity Verification',
                      description: 'This helps our AI distinguish your voice from background noise or other people.',
                    ),
                    const SizedBox(height: 32),

                    // Step Progress Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepIndicator(1, active: true),
                        _buildStepDivider(),
                        _buildStepIndicator(2),
                        _buildStepDivider(),
                        _buildStepIndicator(3),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: _border.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isInitializing ? null : _handleContinue,
                    child: _isInitializing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isInitialized ? 'Start Enrollment' : 'Continue',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Takes less than 1 minute',
                    style: TextStyle(
                      fontSize: 12,
                      color: _secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primary, size: 22),
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
                    fontWeight: FontWeight.bold,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _secondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, {bool active = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? _primary : const Color(0xFFEAE7EA),
      ),
      alignment: Alignment.center,
      child: Text(
        '$step',
        style: TextStyle(
          color: active ? Colors.white : _secondary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: _border.withValues(alpha: 0.5),
    );
  }
}

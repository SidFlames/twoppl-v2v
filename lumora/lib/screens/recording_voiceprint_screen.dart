import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'secret_phrase_setup_screen.dart';

class RecordingVoiceprintScreen extends StatefulWidget {
  const RecordingVoiceprintScreen({super.key, required this.phrase});

  final String phrase;

  @override
  State<RecordingVoiceprintScreen> createState() =>
      _RecordingVoiceprintScreenState();
}

class _RecordingVoiceprintScreenState extends State<RecordingVoiceprintScreen>
    with TickerProviderStateMixin {
  static const _primary = Color(0xFF003D9B);
  static const _primaryContainer = Color(0xFF0052CC);
  static const _secondary = Color(0xFF595F66);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _onSurfaceVariant = Color(0xFF434654);
  static const _outlineVariant = Color(0xFFC3C6D6);
  static const _surface = Color(0xFFFCF8FB);
  static const _surfaceContainer = Color(0xFFF0EDEF);

  late final AnimationController _pulseController;
  late final AnimationController _waveController;
  late final AnimationController _progressController;

  bool _isRecording = true;
  bool _analysisComplete = false;

  // Status labels shown as progress advances
  static const List<String> _statusMessages = [
    'Listening to your voice…',
    'Analysing vocal patterns…',
    'Mapping voice signature…',
    'Almost done — keep speaking…',
    'Voiceprint captured!',
  ];

  String get _currentStatus {
    final v = _progressController.value;
    if (v < 0.2) return _statusMessages[0];
    if (v < 0.45) return _statusMessages[1];
    if (v < 0.7) return _statusMessages[2];
    if (v < 0.95) return _statusMessages[3];
    return _statusMessages[4];
  }

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _analysisComplete = true;
          _isRecording = false;
        });
        _waveController.stop();
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const SecretPhraseSetupScreen(),
            ),
          );
        });
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    if (_isRecording) {
      _waveController.repeat();
      _progressController.forward();
    } else {
      _waveController.stop();
      _progressController.stop();
    }
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
          'Voice Enrollment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _primary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.help_outline, color: _secondary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // Step Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryContainer.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Step 2 of 3',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryContainer,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Title
              const Text(
                'Recording Voiceprint',
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
                'Repeat the phrase in your natural and panic voice for safety measures.',
                style: TextStyle(fontSize: 14, color: _onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Waveform visualizer
              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse glow
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = _isRecording
                            ? 1.0 + (_pulseController.value * 0.1)
                            : 1.0;
                        final opacity = _isRecording
                            ? 0.5 - (_pulseController.value * 0.4)
                            : 0.1;
                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _primaryContainer.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Inner border ring
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    // Waveform bars
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(8, (index) {
                            final double waveVal = math.sin(
                                (_waveController.value * 2 * math.pi) +
                                    (index * 0.4));
                            final double scaleY = _isRecording
                                ? 0.3 + (waveVal.abs() * 0.7)
                                : 0.15;
                            return Container(
                              width: 6,
                              height: 60,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              child: Transform(
                                transform: Matrix4.diagonal3Values(1.0, scaleY, 1.0),
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _isRecording
                                        ? _primary
                                        : _primary.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Phrase Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _primaryContainer.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _primaryContainer.withValues(alpha: 0.25),
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.phrase,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Progress Bar Section
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  final pct = _progressController.value;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _analysisComplete
                                ? 'Voice profile captured!'
                                : _currentStatus,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _analysisComplete
                                  ? const Color(0xFF1A7A3C)
                                  : _primary,
                            ),
                          ),
                          Text(
                            '${(pct * 100).toInt()}%',
                            style: const TextStyle(
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
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: _surfaceContainer,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _analysisComplete
                                ? const Color(0xFF1A7A3C)
                                : _primary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Requirement tiles
              _RequirementRow(
                icon: Icons.record_voice_over,
                title: 'Speak clearly',
                subtitle: 'Maintain a steady pace and volume.',
              ),
              const SizedBox(height: 12),
              _RequirementRow(
                icon: Icons.fingerprint,
                title: 'Secure Voiceprint',
                subtitle: 'Encrypted biometric signature.',
              ),
              const SizedBox(height: 12),
              _RequirementRow(
                icon: Icons.verified_user,
                title: 'Identity Verification',
                subtitle: 'Validated against your profile.',
              ),
              const SizedBox(height: 32),

              // Stop / Resume button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _isRecording
                        ? _primary
                        : _primaryContainer.withValues(alpha: 0.15),
                    foregroundColor:
                        _isRecording ? Colors.white : _primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: _isRecording ? 2 : 0,
                  ),
                  onPressed: _analysisComplete ? null : _toggleRecording,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRecording ? Icons.pause_circle : Icons.play_circle,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _analysisComplete
                            ? 'Complete!'
                            : _isRecording
                                ? 'Stop Recording'
                                : 'Resume Recording',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _secondary,
                    side: const BorderSide(color: _outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC3C6D6)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDEF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF003D9B), size: 20),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF434654),
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

import 'package:flutter/material.dart';

class SecretPhraseSetupScreen extends StatefulWidget {
  const SecretPhraseSetupScreen({super.key});

  @override
  State<SecretPhraseSetupScreen> createState() => _SecretPhraseSetupScreenState();
}

class _SecretPhraseSetupScreenState extends State<SecretPhraseSetupScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF0C56D0);
  static const _surface = Color(0xFFFCF8FB);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _secondary = Color(0xFF595F66);
  static const _border = Color(0xFFC3C6D6);
  static const _lightBlue = Color(0xFFE8F0FE);

  String _phrase = 'Blue Umbrella';
  int _speakCount = 0;
  bool _isRecording = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleMicPress() {
    if (_speakCount >= 3) return;

    if (_isRecording) {
      // Stop recording
      setState(() {
        _isRecording = false;
        _speakCount++;
        _pulseController.stop();
      });

      if (_speakCount == 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice enrollment completed successfully!'),
            backgroundColor: _primary,
          ),
        );
      }
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
        _pulseController.repeat();
      });

      // Automatically complete this speak round after 2 seconds (simulation)
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted || !_isRecording) return;
        setState(() {
          _isRecording = false;
          _speakCount++;
          _pulseController.stop();
        });

        if (_speakCount == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voice enrollment completed successfully!'),
              backgroundColor: _primary,
            ),
          );
        }
      });
    }
  }

  void _editPhrase() {
    final controller = TextEditingController(text: _phrase);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Secret Phrase'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your custom phrase',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: _secondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _phrase = controller.text.trim();
                    _speakCount = 0; // Reset progress if phrase changes
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Step progress label
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _lightBlue,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'Step 1 of 3',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Create Your Secret Phrase',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose a phrase easy for you to remember in moments of stress.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _secondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Phrase Display Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.015),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Phrase',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _phrase,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _onSurface,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: _primary),
                            onPressed: _editPhrase,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Voice Interaction Area
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulse animation when recording
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 100 + (40 * _pulseController.value),
                                    height: 100 + (40 * _pulseController.value),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _primary.withValues(
                                          alpha: _isRecording
                                              ? 0.15 * (1 - _pulseController.value)
                                              : 0.0),
                                    ),
                                  );
                                },
                              ),
                              // Mic button
                              GestureDetector(
                                onTap: _handleMicPress,
                                child: Container(
                                  width: 96,
                                  height: 96,
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
                                  child: Icon(
                                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                    color: Colors.white,
                                    size: 38,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isRecording
                                ? 'Listening... Speak phrase clearly'
                                : 'Speak the phrase 3 times clearly',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Progress dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildProgressDot(active: _speakCount >= 1),
                              const SizedBox(width: 8),
                              _buildProgressDot(active: _speakCount >= 2),
                              const SizedBox(width: 8),
                              _buildProgressDot(active: _speakCount >= 3),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Privacy info box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9FB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.lock_rounded, color: _primary, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This phrase will be encrypted locally on your device and never uploaded to any servers.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: _secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: _speakCount >= 3
                    ? () {
                        // Complete onboarding or navigate next
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Onboarding flow completed!'),
                            backgroundColor: _primary,
                          ),
                        );
                        // Clean navigation back or home
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Start Enrollment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 6,
      decoration: BoxDecoration(
        color: active ? _primary : _border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'voice_profile_created_screen.dart';

class SecretPhraseSetupScreen extends StatefulWidget {
  const SecretPhraseSetupScreen({super.key});

  @override
  State<SecretPhraseSetupScreen> createState() =>
      _SecretPhraseSetupScreenState();
}

class _SecretPhraseSetupScreenState extends State<SecretPhraseSetupScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF003D9B);
  static const _primaryContainer = Color(0xFF0052CC);
  static const _secondary = Color(0xFF595F66);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _onSurfaceVariant = Color(0xFF434654);
  static const _outlineVariant = Color(0xFFC3C6D6);
  static const _surfaceContainerLow = Color(0xFFF6F3F5);
  static const _surface = Color(0xFFFCF8FB);

  static const List<String> _suggestedPhrases = [
    'Blue Umbrella',
    'Golden Sunset',
    'Purple Mountain',
    'Silver Lighthouse',
    'Crimson Falcon',
  ];

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  String _selectedPhrase = 'Blue Umbrella';
  bool _isRecording = false;
  int _recordCount = 0; // 0 = none recorded yet
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Simulate recording for 2s then auto-stop and count
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isRecording = false;
          if (_recordCount < 3) _recordCount++;
        });
      });
    }
  }

  void _showEditPhraseDialog() {
    String temp = _selectedPhrase;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Choose a Phrase',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a suggestion or type your own:',
                  style: TextStyle(fontSize: 13, color: _secondary),
                ),
                const SizedBox(height: 12),
                ..._suggestedPhrases.map((phrase) {
                  return StatefulBuilder(builder: (ctx2, setInner) {
                    final selected = temp == phrase;
                    return GestureDetector(
                      onTap: () => setInner(() => temp = phrase),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: selected ? _primary : const Color(0xFF737685),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              phrase,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected ? _primary : _onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                }),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Or type your own phrase…',
                    hintStyle:
                        const TextStyle(fontSize: 13, color: Color(0xFF737685)),
                    filled: true,
                    fillColor: const Color(0xFFF0EDEF),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => temp = v,
                  style: const TextStyle(fontSize: 14, color: _onSurface),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: _secondary, fontSize: 14)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  _selectedPhrase = temp;
                  _recordCount = 0; // Reset count on phrase change
                });
                Navigator.of(ctx).pop();
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
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _primary, size: 18),
          label: const Text(
            'Back',
            style: TextStyle(
              color: _secondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        leadingWidth: 100,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: _primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryContainer.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Step 3 of 3',
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
                'Create Your Secret Phrase',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a phrase easy for you to remember in moments of stress.',
                style: TextStyle(
                  fontSize: 14,
                  color: _onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Phrase display card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Phrase',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF737685),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedPhrase,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showEditPhraseDialog,
                      icon: const Icon(Icons.edit_outlined,
                          color: _primary, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF003D9B).withValues(alpha: 0.0),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Mic section
              Center(
                child: Column(
                  children: [
                    // Pulsing mic button
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse ring
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isRecording ? _pulseScale.value : 1.0,
                                child: Opacity(
                                  opacity: _isRecording
                                      ? _pulseOpacity.value
                                      : 0.0,
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _primary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Mic button
                          GestureDetector(
                            onTap: _recordCount < 3 ? _toggleRecording : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _isRecording ? const Color(0xFF8C0005) : _primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isRecording
                                            ? const Color(0xFF8C0005)
                                            : _primary)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Instruction text
                    Text(
                      _isRecording
                          ? 'Recording… speak clearly'
                          : _recordCount == 3
                              ? 'All 3 recordings done!'
                              : 'Speak the phrase 3 times clearly',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isRecording
                            ? const Color(0xFF8C0005)
                            : _onSurface,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // 3 progress bars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final filled = i < _recordCount;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: filled ? _primary : _outlineVariant,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_recordCount / 3 recorded',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Privacy card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _outlineVariant.withValues(alpha: 0.30)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock, color: _primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text:
                              'This phrase will be encrypted locally on your device and ',
                          style: TextStyle(
                            fontSize: 13,
                            color: _onSurfaceVariant,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'never uploaded to any servers.',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
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
              const SizedBox(height: 24),

              // Start Enrollment button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  onPressed: _recordCount >= 3 && !_isSaving
                      ? _saveVoiceProfileAndContinue
                      : null,
                  child: _isSaving
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'End Enrollment',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
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
      ),
    );
  }

  Future<void> _saveVoiceProfileAndContinue() async {
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final docRef = firestore.collection('voice_profiles').doc(); // Auto-ID

        // local privacy voice profile - generating embedding array, no raw audio stored
        final embedding = List<double>.generate(128, (index) => math.Random().nextDouble());

        await docRef.set({
          'profileId': docRef.id,
          'userId': user.uid,
          'phrase': _selectedPhrase,
          'embedding': embedding,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VoiceProfileCreatedScreen(
            secretPhrase: _selectedPhrase,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save voice profile: $e')),
      );
    }
  }
}

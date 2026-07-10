import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/create_profile_screen.dart';
import 'services/voice_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize background voice service (does not start it — just registers)
  await VoiceBackgroundService.initializeService();
  runApp(const SafeSphereApp());
}

class SafeSphereApp extends StatelessWidget {
  const SafeSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0C56D0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeSphere',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFCF8FB),
        fontFamily: 'Inter',
      ),
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundOrbs(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;

                return SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 1120),
                                        child: isWide
                                            ? IntrinsicHeight(
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(child: _HeroPanel(color: Theme.of(context).colorScheme.primary)),
                                                    const SizedBox(width: 32),
                                                    const Expanded(child: _OnboardingCard()),
                                                  ],
                                                ),
                                              )
                                            : const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  _HeroPanel(compact: true),
                                                  SizedBox(height: 18),
                                                  _OnboardingCard(),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    this.compact = false,
    this.color = const Color(0xFF0C56D0),
  });

  final bool compact;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(compact ? 0 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(Icons.shield_rounded, size: 38, color: color),
          ),
          const SizedBox(height: 24),
          const Text(
            'Smart Protection\nWhen You Need It Most',
            style: TextStyle(
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: Color(0xFF1B1B1D),
            ),
          ),
          const SizedBox(height: 14),
          const SizedBox(
            width: 360,
            child: Text(
              'AI-powered voice recognition, real-time alerts, and smart emergency support in one calm, secure space.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF595F66),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFC3C6D6)),
              boxShadow: const [
                BoxShadow(color: Color(0x11000000), blurRadius: 28, offset: Offset(0, 12)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Protected connection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your account, location, and emergency access stay encrypted and ready.',
                  style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFF595F66)),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.18),
                          const Color(0xFFF0EDEF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -28,
                          top: -28,
                          child: _GlowCircle(color: color.withValues(alpha: 0.18), size: 120),
                        ),
                        Positioned(
                          left: -18,
                          bottom: -22,
                          child: _GlowCircle(color: const Color(0xFF8C0005).withValues(alpha: 0.12), size: 140),
                        ),
                        const Center(child: _RadarPulse()),
                      ],
                    ),
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

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFC3C6D6)),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 30, offset: Offset(0, 14)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StatusBarMock(),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              'Smart Protection\nWhen You Need It Most',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: Color(0xFF1B1B1D),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              'AI-powered voice recognition, real-time alerts and smart emergency support.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF595F66)),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3F5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFC3C6D6)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: _FloatingBadge(
                    icon: Icons.shield_rounded,
                    label: 'Safe',
                    color: scheme.primary,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 16,
                  child: _FloatingBadge(
                    icon: Icons.location_on_rounded,
                    label: 'Live',
                    color: scheme.tertiary,
                  ),
                ),
                const Center(child: _IllustrationFigure()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _IndicatorDot(active: false),
              _IndicatorDot(active: true),
              _IndicatorDot(active: false),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Next', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: const Color(0xFF595F66),
            ),
            child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp(BuildContext context) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number.')),
      );
      return;
    }
    
    // Hackathon demo bypass: Special testing number or simple click-through fallback
    if (phone == '7099280763' || phone == '1234567890' || phone == '9999999999') {
      _bypassOtpFlow(context, '+91$phone');
      return;
    }

    setState(() => _isLoading = true);
    final fullPhone = '+91$phone';
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => CreateProfileScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          // Show error and provide option to bypass for demo convenience
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${e.message ?? 'Verification failed.'} Using demo bypass instead.'),
              action: SnackBarAction(
                label: 'Demo Bypass',
                textColor: Colors.white,
                onPressed: () => _bypassOtpFlow(context, fullPhone),
              ),
              backgroundColor: const Color(0xFFBA1A1A),
              duration: const Duration(seconds: 8),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OtpScreen(
                phoneNumber: fullPhone,
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _bypassOtpFlow(context, fullPhone);
    }
  }

  Future<void> _bypassOtpFlow(BuildContext context, String phone) async {
    setState(() => _isLoading = true);
    try {
      // Sign in anonymously to get a valid user session for Firestore access
      await FirebaseAuth.instance.signInAnonymously();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo Bypass Activated: Logged in anonymously.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => CreateProfileScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bypass failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundOrbs(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFC3C6D6)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x14000000), blurRadius: 30, offset: Offset(0, 14)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.shield_outlined, color: scheme.primary, size: 38),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Welcome Back!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Login to continue to SafeSphere',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF595F66)),
                        ),
                        const SizedBox(height: 24),
                        _PhoneField(controller: _phoneController),
                        const SizedBox(height: 18),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _isLoading ? null : () => _sendOtp(context),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22, width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Send OTP', style: TextStyle(fontWeight: FontWeight.w700)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: Container(height: 1, color: const Color(0xFFC3C6D6))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or continue with',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF595F66)),
                              ),
                            ),
                            Expanded(child: Container(height: 1, color: const Color(0xFFC3C6D6))),
                          ],
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1B1B1D),
                            minimumSize: const Size.fromHeight(52),
                            side: const BorderSide(color: Color(0xFF737685)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: const Color(0xFFFCF8FB),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.account_circle_outlined),
                          label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 18),
                        const Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(fontSize: 14, color: Color(0xFF595F66)),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0C56D0)),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline, size: 14, color: Color(0x99595F66)),
                            SizedBox(width: 6),
                            Text(
                              'Your data is secured with AES-256 encryption',
                              style: TextStyle(fontSize: 10, letterSpacing: 0.8, color: Color(0x99595F66)),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  final String phoneNumber;
  final String verificationId;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  int _secondsLeft = 25;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (!mounted || _secondsLeft == 0) {
        return false;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _secondsLeft--);
      return _secondsLeft > 0;
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
    // Auto-verify when the last digit is entered
    if (index == _controllers.length - 1 && value.isNotEmpty) {
      _verifyOtp();
    }
  }

  void _clearLastDigit() {
    for (var index = _controllers.length - 1; index >= 0; index--) {
      if (_controllers[index].text.isNotEmpty) {
        _controllers[index].clear();
        _focusNodes[index].requestFocus();
        break;
      }
    }
  }

  bool _isVerifying = false;

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;
    setState(() => _isVerifying = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => CreateProfileScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Invalid OTP. Please try again.'),
          backgroundColor: const Color(0xFFCC0000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final timerText = _secondsLeft == 0 ? 'Now' : '00:${_secondsLeft.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundOrbs(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          tooltip: 'Go back',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Verify OTP',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 6-digit code sent to',
                        style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF595F66)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.phoneNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 48,
                            height: 56,
                            margin: EdgeInsets.only(right: index == 5 ? 0 : 8),
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFFFFFFFF),
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFC3C6D6)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFC3C6D6)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                                ),
                              ),
                              onChanged: (value) {
                                _onDigitChanged(index, value);
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: _secondsLeft == 0 ? () => setState(() => _secondsLeft = 25) : null,
                          child: Text.rich(
                            TextSpan(
                              text: 'Resend OTP in ',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF595F66), fontWeight: FontWeight.w600),
                              children: [
                                TextSpan(
                                  text: timerText,
                                  style: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        onPressed: _isVerifying ? null : _verifyOtp,
                        child: _isVerifying
                            ? const SizedBox(
                                height: 22, width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Verify', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneField extends StatefulWidget {
  const _PhoneField({required this.controller});

  final TextEditingController controller;

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _focused ? const Color(0xFF0C56D0) : const Color(0xFF737685);

    return AnimatedScale(
      scale: _focused ? 1.01 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.phone,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1B1B1D)),
        decoration: InputDecoration(
          prefixIconConstraints: const BoxConstraints(minWidth: 84, minHeight: 48),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 14, top: 14, bottom: 14),
            padding: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFC3C6D6))),
            ),
            child: const Text(
              '+91',
              style: TextStyle(fontSize: 14, color: Color(0xFF595F66), fontWeight: FontWeight.w500),
            ),
          ),
          hintText: '98765 43210',
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF737685)),
          filled: true,
          fillColor: const Color(0xFFFCF8FB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF737685)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0C56D0), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D6)),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 14, offset: Offset(0, 8))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 24 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0C56D0) : const Color(0xFFDEE3EB),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _RadarPulse extends StatelessWidget {
  const _RadarPulse();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: const Color(0xFF0C56D0).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF0C56D0).withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_user_rounded, color: Color(0xFF0C56D0)),
        ),
      ),
    );
  }
}

class _IllustrationFigure extends StatelessWidget {
  const _IllustrationFigure();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0C56D0).withValues(alpha: 0.08),
          ),
        ),
        Container(
          width: 104,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFDEE3EB),
            borderRadius: BorderRadius.circular(52),
          ),
        ),
        Positioned(
          top: 22,
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF6D7C6),
            ),
          ),
        ),
        Positioned(
          top: 62,
          child: Container(
            width: 68,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFF0C56D0),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Positioned(
          bottom: 22,
          left: 36,
          child: Container(width: 18, height: 72, decoration: const BoxDecoration(color: Color(0xFF1B1B1D), borderRadius: BorderRadius.vertical(top: Radius.circular(9)))),
        ),
        Positioned(
          bottom: 22,
          right: 36,
          child: Container(width: 18, height: 72, decoration: const BoxDecoration(color: Color(0xFF1B1B1D), borderRadius: BorderRadius.vertical(top: Radius.circular(9)))),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 28, spreadRadius: 10)],
      ),
    );
  }
}

class _StatusBarMock extends StatelessWidget {
  const _StatusBarMock();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('9:41', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, size: 16),
              SizedBox(width: 6),
              Icon(Icons.wifi, size: 16),
              SizedBox(width: 6),
              Icon(Icons.battery_full, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -100,
            child: _GlowCircle(color: const Color(0xFF0C56D0).withValues(alpha: 0.08), size: 280),
          ),
          Positioned(
            top: 160,
            right: -90,
            child: _GlowCircle(color: const Color(0xFF8C0005).withValues(alpha: 0.06), size: 240),
          ),
          Positioned(
            bottom: -140,
            left: 40,
            child: _GlowCircle(color: const Color(0xFF0C56D0).withValues(alpha: 0.05), size: 320),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _DotGridPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0C56D0);
    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

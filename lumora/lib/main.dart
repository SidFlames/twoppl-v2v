import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  // Background voice service — Android/iOS only (not supported on web)
  if (!kIsWeb) {
    await VoiceBackgroundService.initializeService();
  }
  runApp(const LumoraApp());
}

class LumoraApp extends StatelessWidget {
  const LumoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0C56D0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumora',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFCF8FB),
        fontFamily: 'Inter',
      ),
      home: kIsWeb ? const WelcomeScreen() : const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late final AnimationController _shaderController;
  
  bool _showIntro = true;
  double _introOpacity = 1.0;

  // Animations for logo and tagline
  double _logoOpacity = 0.0;
  double _logoScale = 0.95;
  double _taglineOpacity = 0.0;
  double _taglineTranslation = 10.0;

  @override
  void initState() {
    super.initState();
    _shaderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Skip intro entirely on web
    if (kIsWeb) {
      _showIntro = false;
      return;
    }

    // Trigger logo entrance at 1s
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _logoOpacity = 1.0;
          _logoScale = 1.0;
        });
      }
    });

    // Trigger tagline entrance at 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _taglineOpacity = 1.0;
          _taglineTranslation = 0.0;
        });
      }
    });

    // Fade out entire intro screen starting at 2.5s (takes 1000ms)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _introOpacity = 0.0;
        });
      }
    });

    // Hide intro screen completely at 3.5s
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _showIntro = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _shaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showIntro) {
      return const WelcomeScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedOpacity(
        opacity: _introOpacity,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        child: Stack(
          children: [
            // Center WebGL shader recreation in Flutter
            Center(
              child: SizedBox(
                width: 256,
                height: 256,
                child: AnimatedBuilder(
                  animation: _shaderController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ShaderPainter(_shaderController.value * 2 * pi * 5),
                    );
                  },
                ),
              ),
            ),
            // Brand Centerpiece
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: _logoOpacity,
                    duration: const Duration(milliseconds: 1000),
                    curve: const Cubic(0.16, 1, 0.3, 1),
                    child: AnimatedScale(
                      scale: _logoScale,
                      duration: const Duration(milliseconds: 1000),
                      curve: const Cubic(0.16, 1, 0.3, 1),
                      child: const Text(
                        'LUMORA',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF003D9B),
                          letterSpacing: 8.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: _taglineOpacity,
                    duration: const Duration(milliseconds: 1000),
                    curve: const Cubic(0.16, 1, 0.3, 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      curve: const Cubic(0.16, 1, 0.3, 1),
                      transform: Matrix4.translationValues(0, _taglineTranslation, 0),
                      child: const Text(
                        'PROTECTION THAT MOVES WITH YOU',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF595F66),
                          letterSpacing: 2.4,
                        ),
                      ),
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
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final PageController _pageController;
  Timer? _swipeTimer;
  int _currentPage = 0;

  static const _primary = Color(0xFF003D9B);
  static const _secondary = Color(0xFF595F66);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startSwipeTimer();
  }

  void _startSwipeTimer() {
    _swipeTimer?.cancel();
    _swipeTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % 3;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _swipeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // Restart timer when page changes to give full 3 seconds
    _startSwipeTimer();
  }

  void _navigateToLogin() {
    _swipeTimer?.cancel();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FB),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: Small Header Branding
            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                'Lumora',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  letterSpacing: -0.4,
                ),
              ),
            ),

            // Middle Carousel Section (PageView)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  // Slide 0: Welcome to Lumora
                  _buildWelcomeSlide(),
                  // Slide 1: Guardian Mode
                  _buildGuardianSlide(),
                  // Slide 2: SafeRoute AI
                  _buildSafeRouteSlide(),
                ],
              ),
            ),

            // Bottom Actions & Dots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Smooth animating indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => _buildIndicatorDot(index)),
                  ),
                  const SizedBox(height: 32),

                  // Bottom buttons row matching web design
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _secondary,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          if (_currentPage < 2) {
                            _pageController.animateToPage(
                              _currentPage + 1,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          } else {
                            _navigateToLogin();
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == 2 ? 'Continue' : 'Next',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Privacy tags
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Privacy First',
                        style: TextStyle(fontSize: 11, color: Color(0x99595F66), fontWeight: FontWeight.w600),
                      ),
                      _dot(),
                      const Text(
                        'AI Powered',
                        style: TextStyle(fontSize: 11, color: Color(0x99595F66), fontWeight: FontWeight.w600),
                      ),
                      _dot(),
                      const Text(
                        'Built for You',
                        style: TextStyle(fontSize: 11, color: Color(0x99595F66), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSlide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primary.withValues(alpha: 0.05),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.08),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primary.withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida/AP1WRLuxMbVhuNvaSTR9jIejwGGC4fUNDGLw2p6dwjMFa4LPZsDlnEh4QiLOw6q8wICtNNV7KdAZ4XBG-HJs50UDj-qPgLjasqGB3-azTvmQrjTsF6FvKPSuFS2-l3VMuUkI1q0DI-9ccjIsRmiO4nW5r6FEM8V7OGRfuWPmKWAMIX2z1zBghqWO-cSKZd6LWWwGSxoygWkV-1sGozzErkC6q-mK7EdOKCyzlW85mXXSCSbbFDwN5r70TwYZGTjO',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE4E2E4),
                        child: const Icon(Icons.shield_outlined, color: _primary, size: 64),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Welcome to Lumora',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B1B1D),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Your intelligent safety companion, designed to protect every journey.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: _secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuardianSlide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouncing decorative circles & phone representation
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse decorative circle behind phone
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withValues(alpha: 0.04),
                ),
              ),
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withValues(alpha: 0.06),
                ),
              ),

              // Glass phone simulator
              Container(
                width: 170,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF1B1B1D).withValues(alpha: 0.1),
                    width: 6,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Bouncing Soundwave Bars
                    const _SoundWaveBars(),
                    const Spacer(),
                    // Listening badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Listening...',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Guardian Mode',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B1B1D),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Hands-free voice protection that listens for your secret phrase.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: _secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafeRouteSlide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Zoomed in Map with overlay badges
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Map background container
              Container(
                width: 280,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFC3C6D6).withValues(alpha: 0.5),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAmI53u0lHciEpkdOwBwN4AA39gUshf2UprC07aaCsL9JmoTuQiyIOhfuF-gQiwj89HRbDNRQdZS64evrMwaAXyReZ_SgwBpnWb4MgLgxtzUgTmLWSktPZearqaEALqC6Yp8bPHAO2cz5NhorAEZKCWLrr5ppzE7YEbzqrP11NZhPB9nXqA_22JKUALzLPq4M1hgsQTEwQVqjPiJXQ3lrDxz7RJWY2FqUX2DXCj_tHhdmx8TKzi2uzIdcjqihp5d1bLBkIO04lbz_qE',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: const Color(0xFFF0EDEF));
                  },
                ),
              ),

              // Top Active Status overlay
              Positioned(
                top: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified_user_rounded, color: _primary, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'SafeRoute AI Active',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Floating route comparison card in center
              Positioned(
                bottom: 20,
                width: 220,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.97),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Safe Route Option
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _primary.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _primary,
                              ),
                              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 11),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Safe Route',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _primary),
                                  ),
                                  Text(
                                    'Well-lit • AI Analyzed',
                                    style: TextStyle(fontSize: 8, color: _secondary),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              '12 min',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Fastest Route Option
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F3F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _secondary,
                              ),
                              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 12),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Fastest Route',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'High incident history',
                                    style: TextStyle(fontSize: 8, color: _secondary),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              '9 min',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'SafeRoute AI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B1B1D),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Compare the safest and fastest routes before you travel with SafeRoute AI.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: _secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorDot(int index) {
    final active = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: active ? 24 : 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: active ? _primary : const Color(0xFFC3C6D6),
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFC3C6D6),
      ),
    );
  }
}

// Bouncing Soundwave Widget
class _SoundWaveBars extends StatefulWidget {
  const _SoundWaveBars();

  @override
  State<_SoundWaveBars> createState() => _SoundWaveBarsState();
}

class _SoundWaveBarsState extends State<_SoundWaveBars> with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const barCount = 5;
    const barHeights = [48.0, 80.0, 128.0, 96.0, 64.0];
    const primary = Color(0xFF003D9B);

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(barCount, (index) {
            // Give each bar a slight delay offset
            final offset = sin((_waveController.value * pi) + (index * 0.4));
            final baseHeight = barHeights[index];
            final animatedHeight = 16.0 + (baseHeight - 16.0) * (0.4 + 0.6 * offset.abs());

            return Container(
              width: 8,
              height: animatedHeight,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final double time;

  _ShaderPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Pulse: 0.5 + 0.2 * sin(time * 1.5)
    final pulse = 0.5 + 0.2 * sin(time * 0.3);
    
    // Radial gradient glow
    final glowRadius = maxRadius * pulse;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2563EB).withValues(alpha: 0.4),
          const Color(0xFF2563EB).withValues(alpha: 0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));

    canvas.drawCircle(center, glowRadius, glowPaint);

    // Ripple effect
    for (int i = 0; i < 2; i++) {
      final ringProgress = ((time * 0.05) + (i * 0.5)) % 1.0;
      final ringRadius = maxRadius * 0.3 + (maxRadius * 0.7 * ringProgress);
      final ringOpacity = (1.0 - ringProgress) * 0.06;

      if (ringOpacity > 0) {
        final ringPaint = Paint()
          ..color = const Color(0xFF2563EB).withValues(alpha: ringOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        canvas.drawCircle(center, ringRadius, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) => oldDelegate.time != time;
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
    // Capture context before async gap
    final ctx = context;
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
      if (!ctx.mounted) return;
      _bypassOtpFlow(ctx, fullPhone);
    }
  }

  Future<void> _bypassOtpFlow(BuildContext context, String phone) async {
    setState(() => _isLoading = true);
    final demoEmail = 'demo${phone.replaceAll("+", "")}@safesphere.com';
    const demoPassword = 'safesphere123';

    try {
      // 1. Try to sign in with this demo email
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: demoEmail,
        password: demoPassword,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo Bypass: Signed in successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => CreateProfileScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          // 2. If user doesn't exist, create it
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: demoEmail,
            password: demoPassword,
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demo Bypass: Registered and signed in successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => CreateProfileScreen()),
          );
        } catch (createErr) {
          // 3. Absolute offline fallback: Go directly to dashboard with mock UI values
          _navigateOfflineBypass(context);
        }
      } else {
        _navigateOfflineBypass(context);
      }
    } catch (_) {
      _navigateOfflineBypass(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateOfflineBypass(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo Bypass: Running in offline mock mode.'),
        backgroundColor: Colors.orange,
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => CreateProfileScreen()),
    );
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
                          'Login to continue to Lumora',
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

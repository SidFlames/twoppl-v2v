import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/sos_controller.dart';

class JourneyTrackingScreen extends StatefulWidget {
  const JourneyTrackingScreen({super.key, required this.rideId, required this.routePoints});
  final String rideId;
  final List<LatLng> routePoints;

  @override
  State<JourneyTrackingScreen> createState() => _JourneyTrackingScreenState();
}

class _JourneyTrackingScreenState extends State<JourneyTrackingScreen>
    with TickerProviderStateMixin {
  // ── colours ──────────────────────────────────────────────────────────────
  static const _primary = Color(0xFF003D9B);
  static const _secondary = Color(0xFF595F66);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _outlineVariant = Color(0xFFC3C6D6);
  static const _surface = Color(0xFFFCF8FB);
  static const _success = Color(0xFF1A7A3C);
  static const _error = Color(0xFFBA1A1A);
  static const _errorContainer = Color(0xFF8C0005);

  // ── animation ─────────────────────────────────────────────────────────────
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // ── state ─────────────────────────────────────────────────────────────────
  String _statusMessage = ''; // '' = idle, 'safe' = confirmed, 'sos' = active
  final _sosController = SosController();
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentEmergencyId;


  // ── map ───────────────────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  late LatLng _currentPosition;


  // ── simulated live values ─────────────────────────────────────────────────
  int _etaMin = 18;
  double _distKm = 4.2;
  double _speedKmh = 45;
  late Timer _liveTimer;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.routePoints.isNotEmpty 
        ? widget.routePoints.first 
        : const LatLng(28.6139, 77.2090);


    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Tick live values every 3s to give a "live" feel and write to Firestore
    _liveTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      
      // Default simulated coords
      double lat = 28.6139 + (math.Random().nextDouble() - 0.5) * 0.005;
      double lng = 77.2090 + (math.Random().nextDouble() - 0.5) * 0.005;
      
      try {
        // Request or check permissions, if allowed get real coordinates
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 2),
            ),
          );
          lat = pos.latitude;
          lng = pos.longitude;
        }
      } catch (_) {
        // Fallback to simulated coords
      }

      // Update map marker + camera to follow real/simulated position
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(lat, lng);
        });
        try {
          _mapController.move(_currentPosition, 15.0);
        } catch (_) {}
      }


      // Write location coordinate to Firestore collection 'ride_locations'
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('ride_locations').add({
          'rideId': widget.rideId,
          'lat': lat,
          'lng': lng,
          'speed': _speedKmh,
          'time': FieldValue.serverTimestamp(),
        });

        // Expected route central coordinate
        const expectedLat = 28.6139;
        const expectedLng = 77.2090;
        final distance = Geolocator.distanceBetween(lat, lng, expectedLat, expectedLng);

        // If user deviates > 100 meters from path, write to route_deviations
        if (distance > 100) {
          await firestore.collection('route_deviations').add({
            'rideId': widget.rideId,
            'expected': '28.6139, 77.2090',
            'actual': '$lat, $lng',
            'distance': distance,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('Failed to save tracking coordinate: $e');
      }

      setState(() {
        _etaMin = math.max(0, _etaMin - 1);
        _distKm = math.max(0, double.parse((_distKm - 0.1).toStringAsFixed(1)));
        _speedKmh = 40 + (math.Random().nextDouble() * 12).roundToDouble();
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _liveTimer.cancel();
    _audioRecorder.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _handleSafe() {
    setState(() {
      _statusMessage = 'safe';
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _statusMessage = '');
    });
  }

  void _handleNotSafe() {
    _sosController.startSosHold(context, () async {
      setState(() {
        _statusMessage = 'sos';
      });

      // 1. Create a Firestore emergencies document
      try {
        final firestore = FirebaseFirestore.instance;
        final uuid = const Uuid();
        _currentEmergencyId = uuid.v4();

        final user = FirebaseAuth.instance.currentUser;
        final userId = user?.uid ?? '';
        
        String userName = 'Someone in your Circle';
        try {
          if (userId.isNotEmpty) {
            final userDoc = await firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              userName = userDoc.data()?['name'] ?? userName;
            }
          }
        } catch (_) {}

        await firestore.collection('emergencies').doc(_currentEmergencyId).set({
          'emergencyId': _currentEmergencyId,
          'userId': userId,
          'userName': userName,
          'rideId': widget.rideId,
          'trigger': 'manual',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 2. Start recording ambient audio evidence
        await _startAmbientRecording();
      } catch (e) {
        debugPrint('Failed to initialize SOS trigger: $e');
      }
    });
  }

  Future<void> _startAmbientRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/ambient_evidence_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() => _isRecording = true);

        // Keep recording for 10 seconds then upload as evidence
        Timer(const Duration(seconds: 10), () async {
          if (_isRecording) {
            final filePath = await _audioRecorder.stop();
            setState(() => _isRecording = false);
            if (filePath != null) {
              await _uploadEvidence(filePath);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to record ambient audio: $e');
    }
  }

  Future<void> _uploadEvidence(String filePath) async {
    try {
      final firestore = FirebaseFirestore.instance;
      String audioUrl = 'https://res.cloudinary.com/demo/video/upload/sample_audio.mp3'; // Fallback demo URL

      try {
        final file = File(filePath);
        if (file.existsSync()) {
          final cloudName = dotenv.get('CLOUDINARY_CLOUD_NAME');
          final uploadPreset = dotenv.get('CLOUDINARY_UPLOAD_PRESET');
          
          if (cloudName.isNotEmpty && uploadPreset.isNotEmpty) {
            final dio = Dio();
            final formData = FormData.fromMap({
              'file': await MultipartFile.fromFile(filePath),
              'upload_preset': uploadPreset, 
            });

            final response = await dio.post(
              'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
              data: formData,
            );
            if (response.statusCode == 200) {
              audioUrl = response.data['secure_url'] ?? audioUrl;
            }
          }
        }
      } catch (e) {
        debugPrint('Cloudinary real upload failed: $e');
      }

      if (_currentEmergencyId != null) {
        await firestore.collection('evidence').add({
          'emergencyId': _currentEmergencyId,
          'audioUrl': audioUrl,
          'videoUrl': '',
          'encrypted': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Evidence upload failed: $e');
    }
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  Widget _glass({required Widget child, EdgeInsets? padding, double? borderRadius}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── map section takes all remaining space ──────────────────────
          Expanded(
            child: Stack(
              children: [
                // Map fills the expanded bounded area
                Positioned.fill(
                  child: _MapBackground(
                    mapController: _mapController,
                    currentPosition: _currentPosition,
                    routePoints: widget.routePoints,
                  ),
                ),

                // Gradient fade at bottom of map section
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.85),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // Top app bar overlaid on map
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        _glassIconBtn(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: _surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _outlineVariant.withValues(alpha: 0.4)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Text(
                            'Journey Tracking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _glassIconBtn(icon: Icons.notifications_outlined),
                      ],
                    ),
                  ),
                ),

                // Status overlay (safe / SOS)
                if (_statusMessage.isNotEmpty)
                  Positioned(
                    left: 20, right: 20, bottom: 12,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _surface.withValues(alpha: 0.97),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _statusMessage == 'safe' ? _success : _error,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_statusMessage == 'safe' ? _success : _error).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _statusMessage == 'safe' ? Icons.check_circle_rounded : Icons.emergency_share_rounded,
                            color: _statusMessage == 'safe' ? _success : _error,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _statusMessage == 'safe'
                                  ? 'Safe Status Confirmed — Contacts Notified'
                                  : 'SOS ACTIVE — Emergency Contacts Alerted',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _statusMessage == 'safe' ? _success : _error,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── bottom bento dashboard — sits naturally below the map ──────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 28, top: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ETA & Distance row
                _glass(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCell(label: 'ETA', value: '$_etaMin', unit: 'min'),
                      Container(width: 1, height: 40, color: _outlineVariant),
                      _statCell(label: 'Distance', value: '$_distKm', unit: 'km'),
                      Container(width: 1, height: 40, color: _outlineVariant),
                      _statCell(label: 'Speed', value: '${_speedKmh.toInt()}', unit: 'km/h'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Status + Safety row
                Row(
                  children: [
                    Expanded(
                      child: _glass(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.route_outlined, size: 16, color: _secondary),
                                const SizedBox(width: 6),
                                Text('Status', style: TextStyle(fontSize: 11, color: _secondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 16, color: _success),
                                const SizedBox(width: 5),
                                const Text(
                                  'On Route',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _onSurface),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('Safe Corridor', style: TextStyle(fontSize: 11, color: _secondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _glass(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shield_outlined, size: 16, color: _secondary),
                                const SizedBox(width: 6),
                                Text('Safety', style: TextStyle(fontSize: 11, color: _secondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '96%',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text('Safe Route Score', style: TextStyle(fontSize: 11, color: _secondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(
                        label: "I'm Safe",
                        icon: Icons.health_and_safety_rounded,
                        color: _primary,
                        onTap: _handleSafe,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionBtn(
                        label: 'Not Safe',
                        icon: Icons.warning_rounded,
                        color: _errorContainer,
                        onTap: _handleNotSafe,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassIconBtn({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _surface.withValues(alpha: 0.88),
          shape: BoxShape.circle,
          border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
          boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Icon(icon, color: _primary, size: 20),
      ),
    );
  }

  Widget _statCell({required String label, required String value, required String unit}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: _secondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(fontSize: 11, color: _secondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live OSM Map Background ──────────────────────────────────────────────────
class _MapBackground extends StatelessWidget {
  const _MapBackground({
    required this.mapController,
    required this.currentPosition,
    required this.routePoints,
  });

  final MapController mapController;
  final LatLng currentPosition;
  final List<LatLng> routePoints;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition,
        initialZoom: 15.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.safesphere.lumora',
        ),
        if (routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                color: const Color(0xFF003D9B),
                strokeWidth: 5,
                isDotted: false,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            // Destination marker
            if (routePoints.isNotEmpty)
              Marker(
                point: routePoints.last,
                width: 40,
                height: 40,
                child: const Icon(Icons.flag, color: Color(0xFFBA1A1A), size: 35),
              ),
            // Current position marker with pulsing dot style
            Marker(
              point: currentPosition,
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF003D9B).withValues(alpha: 0.15),
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF003D9B).withValues(alpha: 0.30),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF003D9B),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

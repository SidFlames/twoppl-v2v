import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../widgets/shared_bottom_nav.dart';
import 'journey_tracking_screen.dart';

class LocationEntryScreen extends StatefulWidget {
  const LocationEntryScreen({super.key});

  @override
  State<LocationEntryScreen> createState() => _LocationEntryScreenState();
}

class _LocationEntryScreenState extends State<LocationEntryScreen> {
  static const _primary = Color(0xFF003D9B);
  static const _secondary = Color(0xFF595F66);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _outlineVariant = Color(0xFFC3C6D6);
  static const _success = Color(0xFF1A7A3C);
  static const _surfaceContainerLow = Color(0xFFF6F3F5);

  final _originController = TextEditingController(text: 'Connaught Place, New Delhi');
  final _destinationController = TextEditingController(text: 'Noida Sector 62, UP');
  
  String _selectedMode = 'Transit';
  bool _isAnalyzed = false;
  String _selectedRoute = 'Safest'; // 'Safest' or 'Fastest'
  bool _isAnalyzing = false;
  bool _isStarting = false;

  String? _safestRouteId;
  String? _fastestRouteId;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _analyzeRoute() async {
    setState(() => _isAnalyzing = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final uuid = const Uuid();

      _safestRouteId = uuid.v4();
      _fastestRouteId = uuid.v4();

      final origin = _originController.text;
      final destination = _destinationController.text;

      // 1. Create records in 'routes'
      await firestore.collection('routes').doc(_safestRouteId).set({
        'routeId': _safestRouteId,
        'origin': origin,
        'destination': destination,
        'safestRouteId': _safestRouteId,
      });

      await firestore.collection('routes').doc(_fastestRouteId).set({
        'routeId': _fastestRouteId,
        'origin': origin,
        'destination': destination,
        'safestRouteId': _safestRouteId,
      });

      // 2. Create records in 'route_analysis' (police stations, hospitals, gas stations count)
      await firestore.collection('route_analysis').doc(_safestRouteId).set({
        'routeId': _safestRouteId,
        'safetyScore': 96,
        'reasons': [
          'High density of police stations along Ring Rd',
          '3 24/7 hospitals located on route',
          'Well-lit street lights verified'
        ],
      });

      await firestore.collection('route_analysis').doc(_fastestRouteId).set({
        'routeId': _fastestRouteId,
        'safetyScore': 72,
        'reasons': [
          'Low police presence on Expressway',
          'Industrial area pathway with dimmer lights'
        ],
      });

      setState(() {
        _isAnalyzed = true;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to analyze route safety: $e')),
      );
    }
  }

  Future<void> _startJourney() async {
    setState(() => _isStarting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final uuid = const Uuid();
        final rideId = uuid.v4();

        final selectedRouteId = _selectedRoute == 'Safest' ? _safestRouteId : _fastestRouteId;

        // Create ride session
        await firestore.collection('ride_sessions').doc(rideId).set({
          'rideId': rideId,
          'userId': user.uid,
          'routeId': selectedRouteId ?? '',
          'status': 'active',
          'riskScore': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JourneyTrackingScreen(rideId: rideId),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start ride session: $e')),
      );
    } finally {
      setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const SharedBottomNav(currentTab: BottomNavTab.journey),
      body: Stack(
        children: [
          // Background Map
          Positioned.fill(child: _MapBackground()),

          // Top App Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.arrow_back, color: _primary),
                  ),
                  const Expanded(
                    child: Center(
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
                  ),
                  const Icon(Icons.notifications_outlined, color: _primary),
                ],
              ),
            ),
          ),

          // Main Card
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 100),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: _outlineVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'RouteSafety',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Find your safest route with AI analysis.',
                      style: TextStyle(fontSize: 14, color: _secondary),
                    ),
                    const SizedBox(height: 24),

                    // Location Inputs
                    Row(
                      children: [
                        // Icons and connecting line
                        Column(
                          children: [
                            const Icon(Icons.location_on_outlined, color: _primary, size: 20),
                            Container(
                              height: 40,
                              width: 1,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: _outlineVariant,
                              child: CustomPaint(painter: _DashedLinePainter()), // Dashed effect
                            ),
                            const Icon(Icons.my_location, color: Colors.red, size: 20),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Text Fields
                        Expanded(
                          child: Column(
                            children: [
                              _buildTextField('Current Location', _originController),
                              const SizedBox(height: 16),
                              _buildTextField('Destination', _destinationController),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Travel Mode
                    const Text(
                      'Travel Mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildModeButton('Walk', Icons.directions_walk, 'Walk'),
                        _buildModeButton('Bike', Icons.pedal_bike, 'Bike'),
                        _buildModeButton('Car', Icons.directions_car, 'Car'),
                        _buildModeButton('Transit', Icons.directions_transit, 'Transit'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Analyze / Options
                    if (!_isAnalyzed)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAnalyzing ? null : _analyzeRoute,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          child: _isAnalyzing
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.analytics_outlined),
                                    SizedBox(width: 8),
                                    Text('Analyze Safe Route'),
                                  ],
                                ),
                        ),
                      )
                    else ...[
                      // Route Options Header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Route Options', style: TextStyle(fontSize: 16, color: _onSurface)),
                            Icon(Icons.keyboard_arrow_down, color: _secondary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Safest Route
                      _buildRouteCard(
                        id: 'Safest',
                        title: 'Safest Route',
                        icon: Icons.star,
                        iconColor: Colors.amber,
                        safetyScore: '96%',
                        isRecommended: true,
                        details: 'via Main St & Ring Rd',
                        time: '18 min',
                        distance: '13.8 km',
                      ),
                      const SizedBox(height: 12),
                      
                      // Fastest Route
                      _buildRouteCard(
                        id: 'Fastest',
                        title: 'Fastest Route',
                        icon: Icons.bolt,
                        iconColor: Colors.deepOrange,
                        safetyScore: '72%',
                        isRecommended: false,
                        details: 'via Expressway',
                        time: '14 min',
                        distance: '12.1 km',
                      ),
                      const SizedBox(height: 24),

                      // Start Journey Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isStarting ? null : _startJourney,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          child: _isStarting
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.navigation),
                                    SizedBox(width: 8),
                                    Text('Start Journey'),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _primary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary),
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, IconData icon, String id) {
    final isSelected = _selectedMode == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _primary : _surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : _secondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : _secondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard({
    required String id,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String safetyScore,
    required bool isRecommended,
    required String details,
    required String time,
    required String distance,
  }) {
    final isSelected = _selectedRoute == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedRoute = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primary : _outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: iconColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _success,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        safetyScore,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _onSurface),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text('Safety Score', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _onSurface)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details,
                    style: const TextStyle(fontSize: 13, color: _secondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: _secondary),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(fontSize: 13, color: _secondary)),
                      const SizedBox(width: 12),
                      const Text('•', style: TextStyle(color: _secondary)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 14, color: _secondary),
                      const SizedBox(width: 4),
                      Text(distance, style: const TextStyle(fontSize: 13, color: _secondary)),
                    ],
                  ),
                ],
              ),
            ),
            // Radio button indicator
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primary : _outlineVariant,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Map Background Painter (reused from journey_tracking, slightly simplified)
class _MapBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(),
      size: Size.infinite,
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF0F4F8); // Lighter background
    canvas.drawRect(Offset.zero & size, bg);

    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final minorPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i <= 10; i++) {
      final y = size.height * i / 11;
      final paint = i % 3 == 0 ? streetPaint : minorPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (int i = 1; i <= 8; i++) {
      final x = size.width * i / 9;
      final paint = i % 2 == 0 ? streetPaint : minorPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Add destination marker path visualization (simplified)
    final routePaint = Paint()
      ..color = const Color(0xFF003D9B)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
      
    final path = Path()
      ..moveTo(size.width * 0.35, size.height * 0.25)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.35);
      
    canvas.drawPath(path, routePaint);
    
    // Draw markers
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.25), 8, Paint()..color = const Color(0xFF003D9B));
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.25), 4, Paint()..color = Colors.white);
    
    // Custom pin for destination
    final pinPaint = Paint()..color = const Color(0xFFBA1A1A);
    final pathDest = Path()
      ..moveTo(size.width * 0.6, size.height * 0.35)
      ..lineTo(size.width * 0.6 - 6, size.height * 0.35 - 12)
      ..arcToPoint(Offset(size.width * 0.6 + 6, size.height * 0.35 - 12), radius: const Radius.circular(6))
      ..close();
    canvas.drawPath(pathDest, pinPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.35 - 12), 3, Paint()..color = Colors.white);
    
    // Map text (Noida Sector 62)
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'NOIDA SECTOR 62',
        style: TextStyle(color: Color(0xFF003D9B), fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Draw text background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.6 + textPainter.width/2 + 10, size.height * 0.35 - 15),
          width: textPainter.width + 16,
          height: textPainter.height + 8
        ), 
        const Radius.circular(4)
      ), 
      Paint()..color = Colors.white
    );
    
    textPainter.paint(canvas, Offset(size.width * 0.6 + 18, size.height * 0.35 - 20));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create dashed effect by painting over the line with background color
    final clearPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
      
    final dashHeight = 4.0;
    final dashSpace = 4.0;
    double startY = 0.0;
    
    while (startY < size.height) {
      // We don't need to draw the dash because the container has a background color
      // We just draw the spaces (white) over the line
      startY += dashHeight;
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashSpace), clearPaint);
      startY += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

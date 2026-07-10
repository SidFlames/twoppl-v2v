import 'dart:async';
import 'package:flutter/material.dart';

class ActiveEmergencyScreen extends StatefulWidget {
  const ActiveEmergencyScreen({super.key});

  @override
  State<ActiveEmergencyScreen> createState() => _ActiveEmergencyScreenState();
}

class _ActiveEmergencyScreenState extends State<ActiveEmergencyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    // SOS Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Audio/Video recording timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer(int offsetSeconds) {
    final total = _secondsElapsed + offsetSeconds;
    if (total < 0) return '00:00:00';
    final hrs = (total ~/ 3600).toString().padLeft(2, '0');
    final mins = ((total % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (total % 60).toString().padLeft(2, '0');
    return '$hrs:$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFBA1A1A);
    const textGray = Color(0xFF595F66);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF003D9B)),
          onPressed: () {},
        ),
        title: const Center(
          child: Text(
            'SafeSphere',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF003D9B),
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF003D9B)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Emergency Title
              const Text(
                'EMERGENCY ACTIVE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryRed,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Help is on the way. Your location is being tracked.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textGray,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              // Pulsing SOS Circle
              Expanded(
                child: Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryRed,
                        boxShadow: [
                          BoxShadow(
                            color: primaryRed.withOpacity(0.35),
                            blurRadius: 35,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Status Card List
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFC3C6D6).withOpacity(0.5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Live Location Sharing
                    _buildStatusRow(
                      icon: Icons.location_on,
                      iconColor: const Color(0xFF003D9B),
                      title: 'Live Location Sharing',
                      subtitle: 'Sharing with 3 contacts',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003D9B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: Color(0xFF003D9B),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Color(0xFF003D9B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24, color: Color(0xFFE5E5E5)),
                    
                    // Audio Recording
                    _buildStatusRow(
                      icon: Icons.mic,
                      iconColor: primaryRed,
                      title: 'Audio Recording',
                      subtitle: 'Monitoring environment',
                      trailing: Text(
                        _formatTimer(0),
                        style: const TextStyle(
                          color: textGray,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 24, color: Color(0xFFE5E5E5)),

                    // Recording Video
                    _buildStatusRow(
                      icon: Icons.videocam,
                      iconColor: primaryRed,
                      title: 'Recording Video',
                      subtitle: 'Front camera feed active',
                      trailing: Text(
                        _formatTimer(-2),
                        style: const TextStyle(
                          color: textGray,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 24, color: Color(0xFFE5E5E5)),

                    // Sending Alerts
                    _buildStatusRow(
                      icon: Icons.near_me,
                      iconColor: primaryRed,
                      title: 'Sending Alerts',
                      subtitle: 'Emergency contacts messaged',
                      trailing: const Text(
                        '3/3 Sent',
                        style: TextStyle(
                          color: textGray,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.phone, size: 20),
                label: const Text('Call Emergency Services'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryRed,
                  side: const BorderSide(color: primaryRed, width: 2),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel Emergency'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1B1B1D),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF737685),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

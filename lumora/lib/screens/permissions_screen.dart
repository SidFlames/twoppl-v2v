import 'package:flutter/material.dart';
import 'emergency_contacts_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  static const _primary = Color(0xFF0C56D0);
  static const _surface = Color(0xFFFCF8FB);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _secondary = Color(0xFF595F66);
  static const _border = Color(0xFFC3C6D6);
  static const _tertiaryContainer = Color(0xFFB90009);

  // Initial states from the HTML design
  bool _location = true;
  bool _microphone = true;
  bool _notifications = false;
  bool _camera = false;
  bool _storage = false;
  bool _backgroundLocation = true;
  bool _batteryOptimization = false;

  // Simulator states
  bool _isRequesting = false;
  bool _isGranted = false;

  void _handleGrantAll() {
    if (_isRequesting || _isGranted) return;

    setState(() {
      _isRequesting = true;
    });

    // Simulate permission request logic (similar to HTML script)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isRequesting = false;
        _isGranted = true;

        // Turn all toggles to true
        _location = true;
        _microphone = true;
        _notifications = true;
        _camera = true;
        _storage = true;
        _backgroundLocation = true;
        _batteryOptimization = true;
      });

      // Navigate to EmergencyContactsScreen after 2 seconds
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const EmergencyContactsScreen(),
          ),
        );
      });
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
          'Permissions',
          style: TextStyle(
            color: _primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Main Scrollable Area
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 180, // Space for fixed bottom buttons
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pulse Shield Header Section
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Blur pulse effect
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _primary.withValues(alpha: 0.12),
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Enable Protection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'To provide life-saving protection, SafeSphere requires specific device access. Your data is encrypted and only shared during active emergencies.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: _secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Permissions Card Group
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _border.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPermissionTile(
                          icon: Icons.location_on_outlined,
                          title: 'Location',
                          description:
                              'Enables real-time tracking during SOS and powers SafeRoute AI to guide you through secure zones.',
                          value: _location,
                          onChanged: (val) => setState(() => _location = val),
                          showCheck: _isGranted,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildPermissionTile(
                          icon: Icons.mic_none_outlined,
                          title: 'Microphone',
                          description:
                              'Necessary for hands-free voice-activated SOS and secure voice biometric enrollment.',
                          value: _microphone,
                          onChanged: (val) => setState(() => _microphone = val),
                          showCheck: _isGranted,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildPermissionTile(
                          icon: Icons.notifications_active_outlined,
                          title: 'Notifications',
                          description:
                              'Immediate alerts for threat proximity and status updates from your designated guardians.',
                          value: _notifications,
                          onChanged: (val) => setState(() => _notifications = val),
                          showCheck: _isGranted,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildPermissionTile(
                          icon: Icons.videocam_outlined,
                          title: 'Camera',
                          description:
                              'Captures critical video evidence during SOS triggers for the Evidence Vault.',
                          value: _camera,
                          onChanged: (val) => setState(() => _camera = val),
                          showCheck: _isGranted,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildPermissionTile(
                          icon: Icons.folder_shared_outlined,
                          title: 'Storage',
                          description:
                              'Secures recordings and safety logs within the encrypted on-device Evidence Vault.',
                          value: _storage,
                          onChanged: (val) => setState(() => _storage = val),
                          showCheck: _isGranted,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildPermissionTile(
                          icon: Icons.running_with_errors_outlined,
                          title: 'Background Location',
                          description:
                              'Ensures constant protection even if the app is minimized or the screen is locked.',
                          value: _backgroundLocation,
                          onChanged: (val) => setState(() => _backgroundLocation = val),
                          showCheck: _isGranted,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildPermissionTile(
                          icon: Icons.battery_saver_outlined,
                          title: 'Battery Optimization',
                          description:
                              'Prevents the operating system from suspending safety services in the background.',
                          value: _batteryOptimization,
                          onChanged: (val) => setState(() => _batteryOptimization = val),
                          showCheck: _isGranted,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.lock_outline_rounded, size: 16, color: _secondary),
                      SizedBox(width: 8),
                      Text(
                        'End-to-End Encryption Enabled',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Fixed Bottom Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
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
                      backgroundColor: _isGranted ? _tertiaryContainer : _primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: _primary.withValues(alpha: 0.2),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _handleGrantAll,
                    child: _isRequesting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isGranted ? 'Permissions Granted' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: _secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please review and enable necessary protection permissions.'),
                        ),
                      );
                    },
                    child: const Text(
                      'Review Separately',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showCheck,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: showCheck ? _primary.withValues(alpha: 0.04) : Colors.transparent,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              showCheck ? Icons.check_circle : icon,
              color: showCheck ? _tertiaryContainer : _primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _onSurface,
                      ),
                    ),
                    CustomSwitch(
                      value: value,
                      onChanged: showCheck ? (_) {} : onChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: _secondary,
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

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: value ? const Color(0xFF0C56D0) : const Color(0xFFC3C6D6).withValues(alpha: 0.5),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../screens/main_dashboard_screen.dart';
import '../screens/location_entry_screen.dart';
import '../utils/sos_controller.dart';

enum BottomNavTab { home, sos, journey, history, profile }

class SharedBottomNav extends StatefulWidget {
  final BottomNavTab currentTab;

  const SharedBottomNav({super.key, required this.currentTab});

  @override
  State<SharedBottomNav> createState() => _SharedBottomNavState();
}

class _SharedBottomNavState extends State<SharedBottomNav> {
  static const _primary = Color(0xFF003D9B);
  static const _secondary = Color(0xFF595F66);
  static const _outlineVariant = Color(0xFFC3C6D6);
  static const _error = Color(0xFFBA1A1A);
  
  final _sosController = SosController();

  void _onTabTapped(BottomNavTab tab) {
    if (tab == widget.currentTab) return;

    switch (tab) {
      case BottomNavTab.home:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
          (route) => false,
        );
        break;
      case BottomNavTab.journey:
        // Use standard push, allowing back navigation
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LocationEntryScreen()),
        );
        break;
      case BottomNavTab.history:
      case BottomNavTab.profile:
        // Not implemented yet, do nothing for now
        break;
      case BottomNavTab.sos:
        // SOS is handled by gesture detector, so no direct tap navigation here
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: _outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, label: 'Home', tab: BottomNavTab.home),
            _buildSosNavItem(),
            _buildNavItem(icon: Icons.route, label: 'Journey', tab: BottomNavTab.journey),
            _buildNavItem(icon: Icons.history, label: 'History', tab: BottomNavTab.history),
            _buildNavItem(icon: Icons.person_outline, label: 'Profile', tab: BottomNavTab.profile),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required BottomNavTab tab,
  }) {
    final active = widget.currentTab == tab;
    return GestureDetector(
      onTap: () => _onTabTapped(tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: active
            ? BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? _primary : _secondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _primary : _secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSosNavItem() {
    return GestureDetector(
      onTapDown: (_) => _sosController.startSosHold(context, () => setState(() {})),
      onTapUp: (_) => _sosController.resetSosHold(() => setState(() {})),
      onTapCancel: () => _sosController.resetSosHold(() => setState(() {})),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (_sosController.progress > 0)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      value: _sosController.progress,
                      color: _error,
                      strokeWidth: 3,
                    ),
                  ),
                const Icon(Icons.report, color: _error, size: 28),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'SOS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

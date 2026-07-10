import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/emergency_active_screen.dart';

class SosController {
  // ── Singleton setup ───────────────────────────────────────────────────────
  static final SosController _instance = SosController._internal();
  factory SosController() => _instance;
  SosController._internal();

  // ── State ─────────────────────────────────────────────────────────────────
  double _sosProgress = 0.0;
  Timer? _sosTimer;

  // ── Public API ────────────────────────────────────────────────────────────
  
  double get progress => _sosProgress;

  void startSosHold(BuildContext context, VoidCallback onProgressUpdate) {
    _sosProgress = 0.0;
    onProgressUpdate();
    
    _sosTimer?.cancel();
    _sosTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _sosProgress += 0.01;
      if (_sosProgress >= 1.0) {
        _sosProgress = 1.0;
        _sosTimer?.cancel();
        _triggerSos(context);
      }
      onProgressUpdate();
    });
  }

  void resetSosHold(VoidCallback onProgressUpdate) {
    _sosTimer?.cancel();
    _sosProgress = 0.0;
    onProgressUpdate();
  }

  void _triggerSos(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const EmergencyActiveScreen(),
      ),
    );
  }
}

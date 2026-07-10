import 'dart:async';
import 'package:flutter/material.dart';

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
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('SOS Triggered', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          '🚨 EMERGENCY SOS ACTIVATED!\n\nYour trusted guardians have been notified of your location and environment audio feed.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel SOS', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

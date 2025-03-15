import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class MovementManager {
  late Timer _timer;
  Function(LatLng) onUpdate; // Callback to notify position changes
  LatLng _currentLocation = const LatLng(37.7749, -122.4194); // Default SF
  bool _isMoving = false;

  MovementManager({required this.onUpdate});

  void startMoving() {
    if (_isMoving) return; // Prevent multiple timers
    _isMoving = true;
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateLongitude();
    });
  }

  void stopMoving() {
    if (!_isMoving) return;
    _isMoving = false;
    _timer.cancel();
  }

  void _updateLongitude() {
    double newLongitude = _currentLocation.longitude + 0.001;
    _currentLocation = LatLng(_currentLocation.latitude, newLongitude);
    onUpdate(_currentLocation);
  }

  void dispose() {
    _timer.cancel();
  }
}

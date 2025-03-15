import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CoordinateUpdater {
  LatLng _currentLocation = const LatLng(37.7749, -122.4194); // Default: SF
  late Timer _timer;
  Function(LatLng) onUpdate; // Callback to update UI

  CoordinateUpdater({required this.onUpdate}) {
    _startUpdating();
  }

  void _startUpdating() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateLongitude();
    });
  }

  void _updateLongitude() {
    double newLongitude = _currentLocation.longitude + 0.001; // Move small step
    _currentLocation = LatLng(_currentLocation.latitude, newLongitude);
    onUpdate(_currentLocation); // Notify UI
  }

  void dispose() {
    _timer.cancel();
  }
}

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'movement_manager.dart';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(37.7749, -122.4194); // Default SF
  late MovementManager _movementManager;
  Set<Circle> _circles = {};
  List<LatLng> _trailPoints = [];
  Set<Polyline> _polylines = {};
  bool _isMoving = false;
  String _mapStyle = "";

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _movementManager = MovementManager(onUpdate: (newLocation) {
      setState(() {
        _currentLocation = newLocation;
        _trailPoints.add(newLocation);
        _updateMap();
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation),
        );
      }
    });

    _initializeCircle();
  }

  /// Load the custom map style from `assets/map_style.json`
  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map/map_style.json');
  }

  void _applyMapStyle() {
    if (_mapController != null && _mapStyle.isNotEmpty) {
      _mapController!.setMapStyle(_mapStyle);
    }
  }

  void _initializeCircle() {
    setState(() {
      _circles.add(Circle(
        circleId: const CircleId("moving_circle"),
        center: _currentLocation,
        radius: 10,
        fillColor: Colors.blue.withOpacity(0.5),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ));
    });
  }

  void _updateMap() {
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId("moving_circle"),
          center: _currentLocation,
          radius: 10,
          fillColor: Colors.blue.withOpacity(0.5),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        )
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId("trail"),
          points: _trailPoints,
          color: Colors.red,
          width: 4,
        )
      };
    });
  }

  void _toggleMovement() {
    if (_isMoving) {
      _movementManager.stopMoving();
    } else {
      _movementManager.startMoving();
    }

    setState(() {
      _isMoving = !_isMoving;
    });
  }

  @override
  void dispose() {
    _movementManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 16.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _applyMapStyle(); // Apply style after map is created
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        circles: _circles,
        polylines: _polylines,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMovement,
        child: Icon(_isMoving ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}

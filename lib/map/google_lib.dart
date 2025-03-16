import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unknow/config/colors.dart';
import 'movement_manager.dart';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  late MovementManager _movementManager;
  Set<Circle> _circles = {};
  List<LatLng> _trailPoints = [];
  Set<Polyline> _polylines = {};
  String _mapStyle = "";
  Timer? _recenterTimer;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _initializeLocationStream();
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

  void _initializeLocationStream() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Cannot serve location service");
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("REJECTED LOCATION PERMISSION");
        return;
      }
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      print("Received position: ${position.latitude}, ${position.longitude}");
      LatLng newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = newLocation;
        _trailPoints.add(newLocation);
        _updateMap();
      });
      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(newLocation));
      }
    });
  }


  void _updateMap() {
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId("moving_circle"),
          center: _currentLocation!,
          radius: 10,
          fillColor: UI_White,
          strokeColor: White_Stroke,
          strokeWidth: 2,
        ),
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId("trail"),
          points: _trailPoints,
          color: Colors.red,
          width: 4,
        ),
      };
    });
  }

  void _resetRecenterTimer() {
    _recenterTimer?.cancel();
    _recenterTimer = Timer(const Duration(seconds: 5), () {
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentLocation!, zoom: 16),
          ),
        );
        print(
          "No interaction for 5 seconds. Re-centering to current location.",
        );
      }
    });
  }

  @override
  void dispose() {
    _movementManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocation == null) {
      return Container(
        width: 350,
        height: 350,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Container(
      width: 350,
      height: 350,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation!,
          zoom: 16.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _applyMapStyle(); // Apply style after map is created
        },
        onCameraMove: (CameraPosition position) {
          _resetRecenterTimer();
        },
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        circles: _circles,
        polylines: _polylines,
      ),
    );
  }

  void testLocation() {
    Timer(Duration(seconds: 5), () {
      if (_currentLocation != null) {
        LatLng newLocation = LatLng(
          _currentLocation!.latitude + 1,
          _currentLocation!.longitude + 1,
        );
        setState(() {
          _currentLocation = newLocation;
          _trailPoints.add(newLocation);
          _updateMap();
        });
        print("Test::");
      }
    });
  }
}

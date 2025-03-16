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
  bool _isMoving = false;
  String _mapStyle = "";
  Timer? _recenterTimer;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _updateCurrentLocation();
    //testLocation();
    _movementManager = MovementManager(
      onUpdate: (newLocation) {
        setState(() {
          _currentLocation = newLocation;
          _trailPoints.add(newLocation);
          _updateMap();
        });

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_currentLocation!),
          );
        }
      },
    );
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
      _circles.add(
        Circle(
          circleId: const CircleId("moving_circle"),
          center: _currentLocation!,
          radius: 10,
          fillColor: UI_White,
          strokeColor: White_Stroke,
          strokeWidth: 2,
        ),
      );
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

  Future<void> _updateCurrentLocation() async {
    try{
      LatLng current = await _getCurrentLocation();
      setState(() {
        _currentLocation =current;
        _trailPoints.add(current);
      });
      _initializeCircle();
    }catch(e){
      print("Error getting current location: $e");
    }

  }

  Future<LatLng> _getCurrentLocation() async{
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      print("위치 기반 서비스 누락");
      return Future.error('Location services are disable');
    }

    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      print("위치 허용 거부");
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        print("위치 허용 2 거부 return");
        return Future.error("Location permissions are denied");
      }
    }

    if(permission == LocationPermission.deniedForever) {
      print("영원히 거부");
      return Future.error('Location permission are permanently denied, we cannot request permission');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    if(_currentLocation == null){
      return Container(width:350, height: 350,child: Center(child: CircularProgressIndicator(),));
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


  void testLocation(){
    Timer(Duration(seconds: 5), () {
      if(_currentLocation != null){
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

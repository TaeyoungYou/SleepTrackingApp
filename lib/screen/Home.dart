import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:unknow/screen/home_component/CameraComponent.dart';
import 'package:unknow/screen/home_component/MapComponent.dart';
import 'package:unknow/screen/home_component/PercentageComponent.dart';
import 'package:unknow/screen/home_component/StatusComponent.dart';

import '../config/colors.dart';
import 'home_component/SlidePopup.dart';

class Home extends StatefulWidget {
  final CameraDescription camera;

  const Home({required this.camera, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<double> recentValues = [];
  double averagedPercentage = 0.0;
  double cameraValue = 0.0;
  bool _showPopup = false;
  String _popupMessage = "";

  void updateCameraValue(double newValue) {
    setState(() {
      cameraValue = newValue;
      recentValues.add(cameraValue);
      if (recentValues.length == 5) {
        averagedPercentage = (recentValues.reduce((a, b) => a + b) / 5 - 0.25) * 333.33;
        if (averagedPercentage > 100) averagedPercentage = 100;
        if(averagedPercentage < 0) averagedPercentage = 0;
        recentValues.clear();
        print("================================Average: $averagedPercentage");

        if (averagedPercentage < 20) {
          showPopup("Warning..! Please reset!!");
        }
      }
    });
  }

  void showPopup(String message) {
    setState(() {
      _popupMessage = message;
      _showPopup = true;
    });
    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showPopup = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MapComponent(),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            StatusComponent(result: cameraValue),
                            SizedBox(height: 20),
                            PercentageComponent(percentage: averagedPercentage),
                          ],
                        ),
                        CameraComponent(
                          camera: widget.camera,
                          onValueChanged: updateCameraValue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showPopup)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlidePopup(
                message: _popupMessage,
                displayDuration: Duration(seconds: 3),
              ),
            ),
        ],
      ),
    );
  }
}

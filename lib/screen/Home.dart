import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:unknow/screen/home_component/CameraComponent.dart';
import 'package:unknow/screen/home_component/MapComponent.dart';
import 'package:unknow/screen/home_component/PercentageComponent.dart';
import 'package:unknow/screen/home_component/StatusComponent.dart';
import 'package:vibration/vibration.dart';

import '../config/colors.dart';

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

  void updateCameraValue(double newValue) {
    setState(() {
      cameraValue = newValue;
      recentValues.add(cameraValue);
      if(recentValues.length == 5) {
        averagedPercentage = recentValues.reduce((a,b)=>a+b) * 40;
        if(averagedPercentage > 100) averagedPercentage = 100;
        recentValues.clear();
        print("================================Average: $averagedPercentage");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
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
    );
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:unknow/screen/home_component/CameraComponent.dart';
import 'package:unknow/screen/home_component/MapComponent.dart';
import 'package:unknow/screen/home_component/PercentageComponent.dart';
import 'package:unknow/screen/home_component/StatusComponent.dart';

import '../config/colors.dart';

class Home extends StatelessWidget {
  final CameraDescription camera;

  const Home({required this.camera, super.key});

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
                        StatusComponent(),
                        SizedBox(height: 20),
                        PercentageComponent(percentage: 35),
                      ],
                    ),
                    CameraComponent(camera: camera,),
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

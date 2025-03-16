import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:unknow/screen/Home.dart';
import 'package:unknow/screen/LogIn.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final lastCamera = cameras.last;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'poppins'),
      home: Login(camera: lastCamera),
    ),
  );
}

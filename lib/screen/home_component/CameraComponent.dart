import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../config/colors.dart';

class CameraComponent extends StatefulWidget {
  final CameraDescription camera;

  const CameraComponent({required this.camera, super.key});

  @override
  State<CameraComponent> createState() => _CameraComponentState();
}

class _CameraComponentState extends State<CameraComponent> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isStreaming = false;
  Timer? _imageCaptureTimer;

  @override
  void dispose() {
    _stopStreaming();
    super.dispose();
  }

  void _startStreaming() {
    _controller ??= CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller!
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isStreaming = true;
            });

            _imageCaptureTimer = Timer.periodic(Duration(seconds: 1), (timer){
              //_captureAndSaveImage();
            });
          }
        })
        .catchError((error) {
          print("Error init camera: $error");
          setState(() {
            _controller = null;
            _initializeControllerFuture = null;
            _isStreaming = false;
          });
        });
  }
  // Future<void> _captureAndSaveImage() async {
  //   if(!_isStreaming || _controller == null || !_controller!.value.isInitialized)  return;
  //
  //   try {
  //     final XFile image = await _controller.takePicture();
  //     final Directory directory
  //   } catch(e){
  //     print("Error: $e");
  //   }
  // }

  void _stopStreaming() async {
    if (_controller != null) {
      await _controller!.dispose();
      setState(() {
        _controller = null;
        _initializeControllerFuture = null;
        _isStreaming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 170.5,
          height: 280,
          decoration: BoxDecoration(
            color: UI_White,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child:
              _controller != null && _initializeControllerFuture != null
                  ? CameraStream(
                    camera: widget.camera,
                    controller: _controller!,
                    cameraFuture: _initializeControllerFuture!,
                  )
                  : Center(
                    child: Icon(Icons.videocam_off, color: UI_Black, size: 50),
                  ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: _isStreaming ? _stopStreaming : _startStreaming,
          child: Container(
            width: 170.5,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isStreaming ? UI_Black : UI_White,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: UI_Black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(_isStreaming ? 'ON' : 'OFF',
            style: TextStyle(color: _isStreaming ? UI_White:UI_Black,
            fontSize: 16,
            fontWeight: FontWeight.bold),)
          ),
        ),
      ],
    );
  }
}

class CameraStream extends StatelessWidget {
  final CameraDescription camera;
  final CameraController controller;
  final Future<void> cameraFuture;

  const CameraStream({
    required this.camera,
    required this.controller,
    required this.cameraFuture,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: cameraFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 170.5,
              height: 280,
              child: Transform.scale(
                scaleX:
                    camera.lensDirection == CameraLensDirection.front ? -1 : 1,
                child: CameraPreview(controller),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

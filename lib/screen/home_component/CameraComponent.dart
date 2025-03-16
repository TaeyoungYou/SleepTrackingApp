import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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
  bool _isCapturing = false;
  bool _isModelLoaded = false;
  int _captureCount = 0;
  late Interpreter _interpreter;
  double _predictionResult = 0.0;

  @override
  void initState() {
    _loadModel();
    super.initState();
  }

  @override
  void dispose() {
    _stopStreaming();
    _controller?.dispose();
    _interpreter.close();
    super.dispose();
  }

  Future<void> _startStreaming() async {
    if (_isStreaming) {
      _stopStreaming();
      return;
    }

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isStreaming = true;
            });

            _imageCaptureTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              if (!_isCapturing) _captureAndSendImage();
            });
          }
        })
        .catchError((error) {
          print("Error initializing");
          setState(() {
            _isStreaming = false;
            _controller = null;
            _initializeControllerFuture = null;
          });
        });
  }

  Future<void> _captureAndSendImage() async {
    if(!_isModelLoaded){
      print("⚠️ Model is not yet loaded, skipping image capture.");
      return;
    }
    print(
      "======================================Attempting to capture image....",
    );
    if (!_isStreaming ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      print("not initialzed");
      return;
    }
    if (_isCapturing) {
      print("Still capturing");
      return;
    }
    _isCapturing = true;

    try {
      final XFile image = await _controller!.takePicture();
      final Uint8List imageBytes = await File(image.path).readAsBytes();

      setState(() {
        _captureCount++;
      });

      print("✅ Capture #$_captureCount recorded, sending to AI...");
      await sendImageToAI(imageBytes);
    } catch (e) {
      print("================================sendImageToAI");
      print("Error: $e");
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> sendImageToAI(Uint8List imageBytes) async {
    _runPrediction(imageBytes);
  }

  /// 모델 로딩
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      print("================================_loadModel()");
      print("Error: $e");
    }
  }

  void _runPrediction(Uint8List imageBytes) {
    if(!_isModelLoaded){
      print("⚠️ Model is not yet loaded, skipping prediction.");
      return;
    }
    try{
      // Uint8List -> Image
      img.Image? image = img.decodeImage(imageBytes);
      if(image == null) return;

      // 224x224
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      // image -> float32
      List<List<List<double>>> inputImage = List.generate(224, (y)=>List.generate(224, (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [
          pixel.getChannel(img.Channel.red) / 255,
          pixel.getChannel(img.Channel.green) / 255,
          pixel.getChannel(img.Channel.blue) /255,
        ];
      }));

      var output = List.generate(1, (index)=>List.filled(1, 0.0));

      _interpreter.run([inputImage],output);

      setState(() {
        _predictionResult = output[0][0];
      });

      print("============================Prediction: $_predictionResult");
    }catch(e){
      print("=======================_predict");
      print("Error: ${e}");
    }
  }

  void _stopStreaming() {
    _imageCaptureTimer?.cancel();
    _imageCaptureTimer = null;
    if (_controller != null) {
      _controller!.dispose().then((_) {
        setState(() {
          _controller = null;
          _initializeControllerFuture = null;
          _isStreaming = false;
        });
      });
    } else {
      setState(() {
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
          onTap: () {
            if (_isStreaming) {
              print("Captured: $_captureCount times");
              return _stopStreaming();
            } else {
              _startStreaming();
            }
          },
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
            child: Text(
              _isStreaming ? 'ON' : 'OFF',
              style: TextStyle(
                color: _isStreaming ? UI_White : UI_Black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(CameraApp(camera: firstCamera));
}

class CameraApp extends StatelessWidget {
  final CameraDescription camera;
  const CameraApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CameraScreen(camera: camera));
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      print(e);
    }
  }

  void _showSnackbar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Snackbar triggered!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Preview')),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            top: 16,
            right: 16,
            child: PopupMenuButton<String>(
              onSelected: (value) => _showSnackbar(),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(value: 'Option1', child: Text('Option 1')),
                    PopupMenuItem(value: 'Option2', child: Text('Option 2')),
                  ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: _captureImage,
              child: Text('Capture Image'),
            ),
          ),
          if (_capturedImage != null)
            Positioned(
              bottom: 80,
              left: 20,
              child: Image.file(
                File(_capturedImage!.path),
                width: 100,
                height: 100,
              ),
            ),
        ],
      ),
    );
  }
}

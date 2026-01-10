import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';

import 'controllers/app.dart';
import 'widgets/home_screen.dart';

late AppController appController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMediapipeVision.ensureInitialized();

  final cameras = await availableCameras();
  final camera = cameras.first;
  appController = AppController(camera: camera);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen(), title: 'RepCo');
  }
}

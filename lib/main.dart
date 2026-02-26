import 'package:flutter/material.dart';
import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'controllers/app.dart';
import 'widgets/home_screen.dart';

late AppController appController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMediapipeVision.ensureInitialized();
  final pref = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  // Run this to use the actual video from camera:
  appController = AppController.live(pref);

  // Run this to replay a recording:
  // appController = AppController.replay(assetPath: 'assets/arms-squat.json');

  await WakelockPlus.enable();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      // showPerformanceOverlay: true,
      title: 'RepCo Repetition Counter',
    );
  }
}

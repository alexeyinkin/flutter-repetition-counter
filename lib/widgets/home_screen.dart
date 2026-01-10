import 'package:flutter/material.dart';

import '../main.dart';
import 'camera_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.requestFocus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('Changed to ${state.name}'); // ignore: avoid_print

    switch (state) {
      case AppLifecycleState.resumed: // Foreground
      case AppLifecycleState.inactive: // Background, visible
        appController.tickEmitter.start();
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        appController.tickEmitter.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColoredBox(
          color: Colors.black,
          child: Center(child: CameraOverlayWidget(appController)),
        ),
        Positioned.fill(
          child: GestureDetector(onTap: appController.viewController.nextMode),
        ),
      ],
    );
  }
}

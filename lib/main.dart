import 'package:flutter/material.dart';
import 'package:simpleapp/screens/rotate.dart';
import 'package:simpleapp/screens/audio.dart';
import 'package:simpleapp/screens/gallerie.dart';
import 'package:simpleapp/widgets/custom_bottom_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simpleapp/background_service.dart';
import 'package:camera/camera.dart';
import 'package:simpleapp/screens/personalgallerie.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.notification.isDenied.then((value) async {
    if (value) {
      await Permission.notification.request();
    }
  });

  await Permission.scheduleExactAlarm.isDenied.then((value) async {
    if (value) {
      await Permission.scheduleExactAlarm.request();
    }
  });

  await Permission.camera.isDenied.then((value) async {
    if (value) {
      await Permission.camera.request();
    }
  });

  await Permission.accessMediaLocation.isDenied.then((value) async {
    if (value) {
      await Permission.accessMediaLocation.request();
    }
  });

  await Permission.manageExternalStorage.isDenied.then((value) async {
    if (value) {
      await Permission.manageExternalStorage.request();
    }
  });

  await Permission.storage.isDenied.then((value) async {
    if (value) {
      await Permission.storage.request();
    }
  });

  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  await initializeService();
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.camera});

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Tps',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.blue, primary: Colors.black),
        useMaterial3: true,
      ),
      home: MyHomePage(camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.camera});

  final CameraDescription camera;

  @override
  // ignore: no_logic_in_create_state
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const Rotate(),
      const Gallerie(),
      const Audio(),
      Personalgallerie(camera: widget.camera),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

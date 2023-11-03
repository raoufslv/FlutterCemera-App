import 'package:flutter/material.dart';
import 'package:simpleapp/screens/rotate.dart';
import 'package:simpleapp/screens/audio.dart';
import 'package:simpleapp/screens/gallerie.dart';
import 'package:simpleapp/widgets/custom_bottom_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simpleapp/background_service.dart';

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

  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Tps',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.blue, primary: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Welcome to flutter Tps'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const Rotate(),
    const Gallerie(),
    const Audio(),
  ];

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

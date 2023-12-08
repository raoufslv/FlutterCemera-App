import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Gallerie extends StatefulWidget {
  const Gallerie({super.key});

  @override
  State<Gallerie> createState() => _GallerieState();
}

class _GallerieState extends State<Gallerie> {
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    // Load all '.jpg' images from 'assets/images/' directory
    const String assetPath = 'assets/images/';

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final imagePaths = manifestMap.keys
          .where((String key) => key.contains(assetPath))
          .where((String key) => key.contains('.jpg'))
          .toList();

      setState(() {
        this.imagePaths = imagePaths;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen (gallery and cam)'),
        backgroundColor: Colors.green[400],
      ),
      body: Center(
        child: GridView.count(
          mainAxisSpacing: 10,
          crossAxisCount: 4,
          children: List.generate(imagePaths.length, (index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullscreenImageScreen(
                      imagePath: imagePaths[index],
                    ),
                  ),
                );
              },
              child: Hero(
                tag: imagePaths[index],
                child: Image.asset(imagePaths[index]),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class FullscreenImageScreen extends StatelessWidget {
  final String imagePath;

  const FullscreenImageScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Navigate back when tapped
          },
          child: Hero(
            tag: imagePath,
            child: Image.asset(imagePath),
          ),
        ),
      ),
    );
  }
}

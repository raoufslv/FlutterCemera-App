import 'package:flutter/material.dart';

class Gallerie extends StatefulWidget {
  const Gallerie({super.key});

  @override
  State<Gallerie> createState() => _GallerieState();
}

class _GallerieState extends State<Gallerie> {
  List<String> imagePaths = [
    'assets/images/dog.jpg',
    'assets/images/duck.jpg',
    'assets/images/smily_egg.jpg',
    'assets/images/smily_sky.jpg',
    'assets/images/chicken_baby_in_sky.jpg',
    'assets/images/flower1.jpg',
    'assets/images/flower4.jpg',
    'assets/images/flower8.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen (gallery)'),
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

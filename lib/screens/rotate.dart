import 'package:flutter/material.dart';

class Rotate extends StatefulWidget {
  const Rotate({super.key});

  @override
  State<Rotate> createState() => _RotateState();
}

class _RotateState extends State<Rotate> {
  int _degree = 0;

  void _rotateImage() {
    setState(() {
      _degree += 45;
      if (_degree == 360) {
        _degree = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double angle = _degree * (3.14 / 180);

    return Scaffold(
      appBar: AppBar(
        title: const Text('First Screen (one pic rotation)'),
        backgroundColor: Colors.blue[200],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Transform.rotate(
                angle: angle,
                child: Image.asset('assets/images/dog.jpg', width: 300, height: 300),
              )),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  const EdgeInsets.all(20),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.blue[200]),
              ),
              child: const Text('Rotate image'),
              onPressed: () {
                _rotateImage();
              },
            ),
          ),
        ],
      ),
    );
  }
}

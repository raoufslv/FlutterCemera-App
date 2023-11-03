import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.rotate_90_degrees_ccw),
          label: 'Rotate',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_album),
          label: 'Gallerie',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: 'Audio',
        ),
      ],
    );
  }
}

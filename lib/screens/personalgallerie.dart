import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Personalgallerie extends StatefulWidget {
  const Personalgallerie({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<Personalgallerie> createState() => _PersonalgallerieState();
}

class _PersonalgallerieState extends State<Personalgallerie> {
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    // Get the directory path for the 'Pictures' folder in the external storage
    Directory? picturesDirectory = await getExternalStorageDirectory();
    String picturesPath = '${picturesDirectory?.path}/Pictures';

    // Check if the directory exists
    if (await Directory(picturesPath).exists()) {
      // List all files in the directory
      List<FileSystemEntity> files = Directory(picturesPath).listSync();

      // Filter only .jpg files
      List<File> jpgFiles = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg'))
          .toList();

      // Update the list of images
      setState(() {
        imagePaths = jpgFiles.map((file) => file.path).toList();
      });

      if (kDebugMode) {
        print(imagePaths);
      }
    } else {
      // Create the folder
      await Directory(picturesPath).create(recursive: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('personal gallerie screen'),
        backgroundColor: Colors.green[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // Wrap GridView in Expanded
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
                      child: Image.file(
                        File(imagePaths[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green[400],
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TakePictureScreen(
                      camera: widget.camera,
                      onImageSaved: (String path) {
                        setState(() {
                          imagePaths.add(path);
                        });
                      },
                    ),
                  ),
                );
              },
              child: const Text('Add picture'),
            ),
          ],
        ),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
    required this.onImageSaved,
  }) : super(key: key);

  final CameraDescription camera;
  final Function(String) onImageSaved;

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture'),
        backgroundColor: Colors.green[400],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.green[400],
                  onPressed: () async {
                    try {
                      await _initializeControllerFuture;
                      final image = await _controller.takePicture();
                      // ignore: use_build_context_synchronously
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DisplayPictureScreen(
                            imagePath: image.path,
                            onImageSaved: widget.onImageSaved,
                          ),
                        ),
                      );
                    } catch (e) {
                      if (kDebugMode) {
                        print(e);
                      }
                    }
                  },
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final Function(String) onImageSaved;

  const DisplayPictureScreen(
      {super.key, required this.imagePath, required this.onImageSaved});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display the Picture'),
        backgroundColor: Colors.green[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              File(imagePath),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    // Save the image to the directory 'Pictures' on internal storage of the device
                    final directory = await getExternalStorageDirectory();
                    final newPath = '${directory?.path}/Pictures';
                    if (!await Directory(newPath).exists()) {
                      await Directory(newPath).create(recursive: true);
                    }

                    // Create a new file with a unique name
                    final String newFilePath =
                        path.join(newPath, 'image_${DateTime.now()}.jpg');
                    try {
                      File(imagePath).copySync(newFilePath);
                      // update the list imagePaths
                      onImageSaved(newFilePath);
                    } catch (e) {
                      if (kDebugMode) {
                        print('---------------------Error copying file: $e');
                      }
                    }
                    // Save the image to the gallery
                    await GallerySaver.saveImage(newFilePath);

                    // Navigate back
                    Navigator.pop(context);

                    // Show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Image saved to $newFilePath'),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Icon(Icons.delete),
                  onPressed: () {
                    // Delete the image
                    File(imagePath).deleteSync();
                    Navigator.pop(context); // Navigate back after deletion
                  },
                ),
              ],
            ),
          ],
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
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

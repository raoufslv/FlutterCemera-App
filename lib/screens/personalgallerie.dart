// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class Personalgallerie extends StatefulWidget {
  const Personalgallerie({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<Personalgallerie> createState() => _PersonalgallerieState();
}

class _PersonalgallerieState extends State<Personalgallerie> {
  List<String> mediaPaths = [];

  @override
  void initState() {
    super.initState();
    loadMedia();
  }

  Future<void> loadMedia() async {
    Directory? picturesDirectory = await getExternalStorageDirectory();
    String picturesPath = '${picturesDirectory?.path}/Pictures';

    if (await Directory(picturesPath).exists()) {
      List<FileSystemEntity> files = Directory(picturesPath).listSync();

      List<File> mediaFiles = files
          .whereType<File>()
          .where((file) =>
              file.path.endsWith('.jpg') ||
              file.path.endsWith('.png') ||
              file.path.endsWith('.mp4'))
          .toList();

      setState(() {
        mediaPaths = mediaFiles.map((file) => file.path).toList();
      });

      if (kDebugMode) {
        print(mediaPaths);
      }
    } else {
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
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  // Wrap GridView in Expanded
                  child: GridView.count(
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    crossAxisCount: 3,
                    padding: const EdgeInsets.all(10),
                    childAspectRatio: 5 / 6,
                    children: List.generate(mediaPaths.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  mediaPaths[index].endsWith('.jpg')
                                      ? FullscreenImageScreen(
                                          imagePath: mediaPaths[index],
                                        )
                                      : FullscreenVideoScreen(
                                          videoPath: mediaPaths[index],
                                        ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: mediaPaths[index],
                          child: mediaPaths[index].endsWith('.jpg')
                              ? Image.file(
                                  File(mediaPaths[index]),
                                  fit: BoxFit.fill,
                                  cacheHeight: 300,
                                )
                              : Stack(
                                  children: [
                                    // display the first frame of the video
                                    VideoFirstFrameWidget(
                                      videoPath: mediaPaths[index],
                                    ),
                                    const Positioned(
                                      bottom: 0,
                                      right: 0,
                                      left: 0,
                                      top: 0,
                                      child: Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: Colors.black,
                                            offset: Offset(5.0, 5.0),
                                          ),
                                        ],
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.green[400],
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TakePictureScreen(
                        camera: widget.camera,
                        onImageSaved: (String path) {
                          setState(() {
                            mediaPaths.add(path);
                          });
                        },
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoFirstFrameWidget extends StatefulWidget {
  final String videoPath;

  const VideoFirstFrameWidget({Key? key, required this.videoPath})
      : super(key: key);

  @override
  _VideoFirstFrameWidgetState createState() => _VideoFirstFrameWidgetState();
}

class _VideoFirstFrameWidgetState extends State<VideoFirstFrameWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      File(widget.videoPath),
    )..initialize().then((_) {
        if (mounted) {
          // Check if the widget is still mounted before calling setState
          setState(() {
            _controller.pause();
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 10 / 12,
      // play the video without sound
      child: VideoPlayer(_controller),
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

  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture or video'),
        backgroundColor: Colors.green[400],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview
            return Stack(
              children: [
                // Fullscreen Camera Preview
                Positioned.fill(
                  child: CameraPreview(_controller),
                ),
                // Floating buttons at the bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.green[400],
                        onPressed: () async {
                          try {
                            await _initializeControllerFuture;
                            final image = await _controller.takePicture();
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
                      FloatingActionButton(
                        backgroundColor: Colors.green[400],
                        onPressed: () async {
                          try {
                            await _initializeControllerFuture;

                            if (!isRecording) {
                              // Start video recording
                              await _controller.startVideoRecording();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Recording video...'),
                                ),
                              );
                            } else {
                              // Stop video recording and get the path
                              final videoPath =
                                  await _controller.stopVideoRecording();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Stopped recording video'),
                                ),
                              );

                              // Navigate to the DisplayVideoScreen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DisplayVideoScreen(
                                    videoPath: videoPath.path,
                                    onVideoSaved: widget.onImageSaved,
                                  ),
                                ),
                              );
                            }

                            // Toggle recording state
                            setState(() {
                              isRecording = !isRecording;
                            });
                          } catch (e) {
                            if (kDebugMode) {
                              print(e);
                            }
                          }
                        },
                        child: Icon(
                          isRecording ? Icons.stop : Icons.videocam,
                        ),
                      ),
                    ],
                  ),
                ),
                // make a button to flip the camera
                Positioned(
                  top: 0,
                  right: 0,
                  child: FloatingActionButton(
                    backgroundColor: Colors.green[400],
                    onPressed: () async {
                      try {
                        await _initializeControllerFuture;
                        final lensDirection =
                            _controller.description.lensDirection;
                        CameraDescription newDescription;
                        if (lensDirection == CameraLensDirection.front) {
                          newDescription = await availableCameras().then(
                            (value) => value.firstWhere(
                              (element) =>
                                  element.lensDirection ==
                                  CameraLensDirection.back,
                            ),
                          );
                        } else {
                          newDescription = await availableCameras().then(
                            (value) => value.firstWhere(
                              (element) =>
                                  element.lensDirection ==
                                  CameraLensDirection.front,
                            ),
                          );
                        }
                        setState(() {
                          _controller = CameraController(
                            newDescription,
                            ResolutionPreset.medium,
                          );
                          _initializeControllerFuture =
                              _controller.initialize();
                        });
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                      }
                    },
                    child: const Icon(Icons.flip_camera_ios),
                  ),
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

class DisplayVideoScreen extends StatelessWidget {
  final String videoPath;
  final Function(String) onVideoSaved;

  const DisplayVideoScreen(
      {super.key, required this.onVideoSaved, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display the Video'),
        backgroundColor: Colors.green[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: VideoPlayerWidget(videoPath: videoPath)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    // Save the video to the directory 'Pictures' on internal storage of the device
                    final directory = await getExternalStorageDirectory();
                    final newPath = '${directory?.path}/Pictures';
                    if (!await Directory(newPath).exists()) {
                      await Directory(newPath).create(recursive: true);
                    }

                    // Create a new file with a unique name
                    final String newFilePath =
                        path.join(newPath, 'video_${DateTime.now()}.mp4');
                    try {
                      File(videoPath).copySync(newFilePath);
                      // update the list mediaPaths
                      onVideoSaved(newFilePath);
                    } catch (e) {
                      if (kDebugMode) {
                        print('---------------------Error copying file: $e');
                      }
                    }
                    // Save the video to the gallery
                    await GallerySaver.saveVideo(newFilePath);

                    // Navigate back
                    Navigator.pop(context);

                    // Show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Video saved to $newFilePath'),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Icon(Icons.delete),
                  onPressed: () {
                    // Delete the video
                    File(videoPath).deleteSync();
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

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      File(widget.videoPath),
    )..initialize().then((_) {
        if (mounted) {
          // Check if the widget is still mounted before calling setState
          setState(() {
            _controller.play();
          });
        }
      });

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
      aspectRatio: _controller.value.aspectRatio / 1.5,
      // Other customization options can be added here
    );
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
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
                      // update the list mediaPaths
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

class FullscreenVideoScreen extends StatelessWidget {
  final String videoPath;

  const FullscreenVideoScreen({Key? key, required this.videoPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fullscreen Video'),
        backgroundColor: Colors.green[400],
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Navigate back when tapped
          },
          child: VideoPlayerWidget(videoPath: videoPath),
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
      appBar: AppBar(
        title: const Text('Fullscreen Video'),
        backgroundColor: Colors.green[400],
      ),
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

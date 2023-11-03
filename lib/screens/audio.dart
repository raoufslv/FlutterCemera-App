import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class Audio extends StatefulWidget {
  const Audio({Key? key}) : super(key: key);

  @override
  State<Audio> createState() => _AudioState();
}

Future<String> isRunning() async {
  if (await FlutterBackgroundService().isRunning()) {
    return 'running';
  } else {
    return 'stopped';
  }
}

class _AudioState extends State<Audio> {
  late AudioPlayer player;
  late String statuss;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    isRunning().then((value) {
      setState(() {
        statuss = value;
      });
    });
  }

  Future<void> _playSound() async {
    try {
      await player.setAsset('assets/sounds/ExtremeSport.mp3');
      player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> _stopSound() async {
    await player.stop();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    status();
  }

  Future<String> status() async {
    if (await FlutterBackgroundService().isRunning()) {
      statuss = 'running';
      setState(() {
        statuss = statuss;
      });
      return statuss;
    } else {
      statuss = 'stopped';
      setState(() {
        statuss = statuss;
      });
      return statuss;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
        backgroundColor: Colors.purple[100],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  'service status: $statuss',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          await FlutterBackgroundService().startService();
                          setState(() {});
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 225, 190, 231)),
                        ),
                        child: const Text('Start Service')),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        FlutterBackgroundService().invoke('stopService');
                        setState(() {});
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 225, 190, 231)),
                      ),
                      child: const Text('Stop service'),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'normal audio',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _playSound,
                      child: const Text('Play'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _stopSound,
                      child: const Text('Stop'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                if (statuss == 'running')
                  Text(
                    'audio in background',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                if (statuss == 'running')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => {
                          FlutterBackgroundService().invoke('setAsBackground'),
                          FlutterBackgroundService().invoke('startAudio')
                        },
                        child: const Text('Play'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () =>
                            {FlutterBackgroundService().invoke('stopAudio')},
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                const SizedBox(height: 40),
                if (statuss == 'running')
                  Text(
                    'audio in foreground',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                if (statuss == 'running')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => {
                          FlutterBackgroundService().invoke('setAsForeground'),
                          FlutterBackgroundService().invoke('startAudio')
                        },
                        child: const Text('Play'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () =>
                            {FlutterBackgroundService().invoke('stopAudio')},
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

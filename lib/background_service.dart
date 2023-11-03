import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // do not start service automatically
      autoStart: false,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final player = AudioPlayer();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: 'My App',
        content: '(Foreground service) Updated at ${DateTime.now()}',
      );
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('startAudio').listen((event) async {
      await player.setAsset('assets/sounds/ExtremeSport.mp3');
      player.play();
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: 'Simple App',
          content:
              'playing audio (Foreground service), Updated at ${DateTime.now()}',
        );
      }
      // if the audio completed, update the notification
      player.playerStateStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          service.setForegroundNotificationInfo(
            title: 'Simple App',
            content:
                'audio completed (Foreground service), Updated at ${DateTime.now()}',
          );
        }
      });
    });

    service.on('stopAudio').listen((event) async {
      await player.stop();
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: 'Simple App',
          content:
              'audio stopped (Foreground service), Updated at ${DateTime.now()}',
        );
      }
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

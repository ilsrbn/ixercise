import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/app/shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          audioFocus: AndroidAudioFocus.none,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notification,
        ),
      ),
    );
  } catch (_) {
    // Audio context unavailable in some environments.
  }
  runApp(
    ProviderScope(
      child: IxerciseApp(),
    ),
  );
}

// Datei: pages\events\event\itemtap_audio.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:flutter/services.dart' show rootBundle;

int playCount = 0;
int soundCount = 0;

Future<void> playTapSound() async {
  if (kIsWeb) {
    _playWeb();
  } else {
    _playNative();
  }
}

Future<void> _playNative() async {
  try {
    if (playCount == 30 || playCount == 60){
      if (soundCount == 9) {
        soundCount = 0;
      } else {
        soundCount +=1;
      }
    } 
    if (playCount <= 25) {
      playCount +=1;
      _playUsingJust();
    } else if (playCount <= 50){
      playCount +=1;
      _playWebFallback();
    } else {
      playCount = 0;
    }
  } catch (_) {}
}

Future<void> _playWeb() async {
  try {
    if (playCount <= 25) {
      playCount +=1;
      _playUsingJust();
    } else if (playCount <= 50){
      playCount +=1;
      _playWebFallback();
    } else {
      playCount = 0;
    }
  } catch (_) {}
}

Future<void> _playUsingJust() async {
  try {
    final data = await rootBundle.load('assets/sounds/ontap_low_$soundCount.mp3');
    final bytes = data.buffer.asUint8List();
    final ja.AudioPlayer _justPlayer = ja.AudioPlayer();
    await _justPlayer.setAudioSource(ja.AudioSource.uri(Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg')));
    await _justPlayer.play();
  } catch (e) {}
}

Future<void> _playWebFallback() async {
  try {
    final data = await rootBundle.load('assets/sounds/ontap_low_$soundCount.mp3');
    final bytes = data.buffer.asUint8List();
    final src = Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg').toString();
    final player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    player.setReleaseMode(ReleaseMode.stop);
    await player.play(UrlSource(src), volume: 0.7);
    player.onPlayerComplete.listen((_) => player.dispose());
  } catch (e) {}
}

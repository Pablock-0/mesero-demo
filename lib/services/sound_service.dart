import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const _addSounds = ['gre.wav', 'mmm.wav', 'nam.wav', 'rico.wav'];

  final _random = Random();
  final _player = AudioPlayer();

  bool enabled = false;

  Future<void> playAdd() async {
    if (!enabled) return;
    final file = _addSounds[_random.nextInt(_addSounds.length)];
    await _player.play(AssetSource('audio/$file'));
  }

  Future<void> playCuenta() async {
    if (!enabled) return;
    await _player.play(AssetSource('audio/kch.wav'));
  }
}

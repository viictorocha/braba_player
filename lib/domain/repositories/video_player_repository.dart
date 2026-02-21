import 'package:flutter/material.dart';

abstract class IVideoPlayerRepository {
  Widget buildPlayer(String videoId);
  void play();
  void pause();
  void seekTo(Duration position);
  void dispose();
  Stream<Duration> get positionStream;
  Stream<bool> get isReadyStream;
}

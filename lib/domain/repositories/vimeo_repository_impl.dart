import 'package:flutter/material.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import '../../domain/repositories/video_player_repository.dart';

class VimeoRepositoryImpl implements IVideoPlayerRepository {
  @override
  Widget buildPlayer(String videoId) {
    return Container(
      key: ValueKey(videoId), // Força o rebuild ao trocar de vídeo
      child: VimeoVideoPlayer(videoId: videoId),
    );
  }

  @override
  void play() {}

  @override
  void pause() {}

  @override
  void seekTo(Duration position) {}

  @override
  void dispose() {}

  @override
  Stream<Duration> get positionStream => const Stream.empty();

  @override
  Stream<bool> get isReadyStream => Stream.value(true).asBroadcastStream();
}

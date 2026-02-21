import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../domain/repositories/video_player_repository.dart';

class YoutubeRepositoryImpl implements IVideoPlayerRepository {
  late YoutubePlayerController _controller;

  @override
  Widget buildPlayer(String videoId) {
    // Configuramos o player para o estilo "Braba" (M3, sem marca exagerada)
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true, // Evita recomendações aleatórias no fim
        mute: false,
      ),
    );

    return YoutubePlayer(controller: _controller, aspectRatio: 16 / 9);
  }

  @override
  void play() => _controller.playVideo();

  @override
  void pause() => _controller.pauseVideo();

  @override
  void seekTo(Duration position) =>
      _controller.seekTo(seconds: position.inSeconds.toDouble());

  @override
  void dispose() => _controller.close();

  @override
  Stream<Duration> get positionStream => _controller.getCurrentPositionStream();

  @override
  Stream<bool> get isReadyStream => _controller.videoStateStream.map((_) {
    // Acessamos o estado diretamente do valor atual do controller
    final s = _controller.value.playerState;

    return s == PlayerState.playing ||
        s == PlayerState.paused ||
        s == PlayerState.buffering ||
        s == PlayerState.cued;
  });
}

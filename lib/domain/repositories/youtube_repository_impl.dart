import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../domain/repositories/video_player_repository.dart';

class YoutubeRepositoryImpl implements IVideoPlayerRepository {
  late YoutubePlayerController _controller;

  @override
  @override
  Widget buildPlayer(String videoId) {
    final String currentOrigin = Uri.base.origin;

    _controller = YoutubePlayerController(
      params: YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
        mute: false,
        origin: currentOrigin,
        enableCaption: true,
        showVideoAnnotations: false,
      ),
    )..loadVideoById(videoId: videoId);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
    );
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
    final s = _controller.value.playerState;

    return s == PlayerState.playing ||
        s == PlayerState.paused ||
        s == PlayerState.buffering ||
        s == PlayerState.cued;
  });
}

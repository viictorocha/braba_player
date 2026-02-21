import 'package:flutter/material.dart';
import '../../domain/repositories/video_player_repository.dart';
import 'package:get_it/get_it.dart';

class BrabaVideoPlayer extends StatefulWidget {
  final String videoId;
  const BrabaVideoPlayer({super.key, required this.videoId});

  @override
  State<BrabaVideoPlayer> createState() => _BrabaVideoPlayerState();
}

class _BrabaVideoPlayerState extends State<BrabaVideoPlayer> {
  final _videoRepo = GetIt.I<IVideoPlayerRepository>();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Color(0xFF1C1C1E), Color(0xFF121214)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _videoRepo.buildPlayer(widget.videoId),
      ),
    );
  }
}

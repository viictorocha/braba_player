import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import '../../domain/repositories/video_player_repository.dart';

class DirectVideoRepositoryImpl implements IVideoPlayerRepository {
  VideoPlayerController? _controller;
  String? _currentVideoUrl;

  @override
  Widget buildPlayer(String videoUrl) {
    // Mantém a instância se a URL for a mesma (evita reset ao girar tela)
    if (_controller != null && _currentVideoUrl == videoUrl) {
      return _VideoWithControls(controller: _controller!);
    }

    _controller?.dispose();
    _currentVideoUrl = videoUrl;
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    return FutureBuilder(
      future: _controller!.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!_controller!.value.isPlaying) _controller!.play();
          return _VideoWithControls(controller: _controller!);
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE0C097),
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  @override
  void play() => _controller?.play();
  @override
  void pause() => _controller?.pause();
  @override
  void seekTo(Duration pos) => _controller?.seekTo(pos);

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  Stream<Duration> get positionStream => const Stream.empty();
  @override
  Stream<bool> get isReadyStream => Stream.value(true);
}

class _VideoWithControls extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoWithControls({required this.controller});

  @override
  State<_VideoWithControls> createState() => _VideoWithControlsState();
}

class _VideoWithControlsState extends State<_VideoWithControls> {
  bool _showControls = true;
  double _playbackSpeed = 1.0;
  Timer? _hideTimer;
  String _feedbackText = ""; // Ex: "+10s"

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  // Gerencia o desaparecimento automático dos controles
  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _startHideTimer();
    });
  }

  void _showFeedback(String text) {
    setState(() => _feedbackText = text);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _feedbackText = "");
    });
  }

  void _toggleFullscreen() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    _startHideTimer();
  }

  void _changeSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0)
        _playbackSpeed = 1.5;
      else if (_playbackSpeed == 1.5)
        _playbackSpeed = 2.0;
      else if (_playbackSpeed == 2.0)
        _playbackSpeed = 0.5;
      else
        _playbackSpeed = 1.0;
      widget.controller.setPlaybackSpeed(_playbackSpeed);
    });
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return MouseRegion(
      onHover: (_) => _toggleControls(),
      child: GestureDetector(
        onTap: _toggleControls,
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. CAMADA BASE: O VÍDEO
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: VideoPlayer(widget.controller),
                ),
              ),

              // 2. CAMADA DE GESTOS (Double Tap para Seek)
              // Fica atrás dos botões mas na frente do vídeo
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onDoubleTap: () {
                          final newPos =
                              widget.controller.value.position -
                              const Duration(seconds: 10);
                          widget.controller.seekTo(newPos);
                          _showFeedback("-10s");
                        },
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onDoubleTap: () {
                          final newPos =
                              widget.controller.value.position +
                              const Duration(seconds: 10);
                          widget.controller.seekTo(newPos);
                          _showFeedback("+10s");
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 3. CAMADA DE FEEDBACK VISUAL (Bolha central de skip)
              if (_feedbackText.isNotEmpty)
                IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _feedbackText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // 4. CAMADA DE CONTROLES (HUD)
              IgnorePointer(
                ignoring: !_showControls,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Stack(
                    children: [
                      // Gradientes de leitura
                      _buildGradients(),

                      // Play/Pause Central (Usando ValueListenable para performance)
                      ValueListenableBuilder(
                        valueListenable: widget.controller,
                        builder: (context, VideoPlayerValue value, child) {
                          return Center(
                            child: IconButton(
                              onPressed: () {
                                value.isPlaying
                                    ? widget.controller.pause()
                                    : widget.controller.play();
                                _startHideTimer();
                              },
                              icon: Icon(
                                value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: const Color(0xFFE0C097),
                                size: isLandscape ? 90 : 70,
                              ),
                            ),
                          );
                        },
                      ),

                      // Botões Inferiores Direita
                      Positioned(
                        bottom: isLandscape ? 30 : 25,
                        right: 15,
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: _changeSpeed,
                              child: Text(
                                "${_playbackSpeed}x",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _toggleFullscreen,
                              icon: Icon(
                                isLandscape
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Barra de Progresso Customizada
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: VideoProgressIndicator(
                          widget.controller,
                          allowScrubbing: true,
                          padding: const EdgeInsets.only(top: 20),
                          colors: const VideoProgressColors(
                            playedColor: Color(0xFFE0C097),
                            bufferedColor: Colors.white24,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradients() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
      ),
    );
  }
}

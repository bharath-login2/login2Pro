import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class CallRecordingPlayer extends StatefulWidget {
  final String audioUrl;

  const CallRecordingPlayer({
    super.key,
    required this.audioUrl,
  });

  @override
  State<CallRecordingPlayer> createState() => _CallRecordingPlayerState();
}

class _CallRecordingPlayerState extends State<CallRecordingPlayer> {
  late final AudioPlayer _player;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // Listen to player state changes to force UI updates immediately
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _togglePlayback() async {
    if (_loading) return;

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      if (_player.playing) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.idle ||
            _player.processingState == ProcessingState.completed) {
          await _player.setUrl(widget.audioUrl);
        }

        await _player.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to play recording';
        });
      }
      debugPrint('Audio playback error: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';

    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = _player.playerState;
    final isPlaying = playerState.playing;
    final processingState = playerState.processingState;
    final isCompleted = processingState == ProcessingState.completed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Play / Pause Button with Blue Color and Reliable State
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: _loading ? null : _togglePlayback,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      )
                    : Icon(
                        isPlaying && !isCompleted
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        size: 36,
                        color: Colors.blue, // Changed from purple to blue
                      ),
              ),
            ),
            const SizedBox(width: 8),

            // Slider & Timers
            Expanded(
              child: StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = _player.duration ?? Duration.zero;

                  final maxValue = total.inMilliseconds > 0
                      ? total.inMilliseconds.toDouble()
                      : 1.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor:
                              Colors.blue, // Slider active track to blue
                          thumbColor: Colors.blue, // Slider thumb to blue
                          trackHeight: 3.5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14.0,
                          ),
                        ),
                        child: Slider(
                          min: 0,
                          max: maxValue,
                          value: position.inMilliseconds
                              .toDouble()
                              .clamp(0.0, maxValue),
                          onChanged: total.inMilliseconds > 0
                              ? (value) {
                                  _player.seek(
                                    Duration(
                                      milliseconds: value.round(),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Text(
                          '${_formatDuration(position)} / ${_formatDuration(total)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

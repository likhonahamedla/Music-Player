import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'model_class/song_clas.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final List<SongClass> _playList = [
    SongClass(
      title: '3-second synth melody',
      artist: "No Artist",
      url: 'http://samplelib.com/lib/preview/mp3/sample-3s.mp3',
      durationSeconds: 3,
    ),
    SongClass(
      title: '6-second synth melody',
      artist: "No Artist",
      url: 'http://samplelib.com/lib/preview/mp3/sample-6s.mp3',
      durationSeconds: 6,
    ),
    SongClass(
      title: '9-second melody using background drums',
      artist: "No Artist",
      url: 'http://samplelib.com/lib/preview/mp3/sample-9s.mp3',
      durationSeconds: 9,
    ),
    SongClass(
      title: '12-second melody using flute and whole drum ensemble',
      artist: "No Artist",
      url: 'http://samplelib.com/lib/preview/mp3/sample-12s.mp3',
      durationSeconds: 12,
    ),
    SongClass(
      title: '15 seconds of awesome music without using drums',
      artist: "No Artist",
      url: 'http://samplelib.com/lib/preview/mp3/sample-15s.mp3',
      durationSeconds: 15,
    ),
  ];
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  @override
  void initState() {
    _listenPlayer();
    _playSong(_currentIndex);
    super.initState();
  }

  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds.remainder(60);
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final SongClass song = _playList[_currentIndex];
    final double maxSecond = max(_duration.inSeconds.toDouble(), 1);
    final double currentSecond = _position.inSeconds.toDouble().clamp(
      0,
      maxSecond,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          Card(
            color: Colors.white70,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                children: [
                  Center(
                    child: Lottie.asset(
                      'asset/music.json',
                      repeat: true,
                      reverse: false,
                      animate: _isPlaying,
                    ),
                  ),
                  Text(song.title),
                  Text(song.artist),
                  Slider(
                    min: 0,
                    max: maxSecond,
                    value: currentSecond,
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(position);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: _previousSong,
                        icon: Icon(Icons.skip_previous, size: 40),
                      ),
                      IconButton(
                        onPressed: _togglePlayer,
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_circle_fill,
                          size: 40,
                        ),
                      ),
                      IconButton(
                        onPressed: _nextSong,
                        icon: Icon(Icons.skip_next, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemCount: _playList.length,
              itemBuilder: (context, index) {
                final SongClass song = _playList[index];
                final bool isCurrent = index == _currentIndex;
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  trailing: Icon(
                    isCurrent && _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                  ),
                  onTap: () => _playSong(index),
                  selected: isCurrent,
                  selectedColor: Colors.deepPurpleAccent,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playSong(int index) async {
    _currentIndex = index;
    final song = _playList[index];
    setState(() {
      _position = Duration.zero;
      _duration = Duration(seconds: song.durationSeconds);
    });
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(song.url));
  }

  Future<void> _nextSong() async {
    final int nextSong = (_currentIndex + 1) % _playList.length;
    await _playSong(nextSong);
  }

  Future<void> _previousSong() async {
    final int previousSong =
        (_currentIndex - 1 + _playList.length) % _playList.length;
    await _playSong(previousSong);
  }

  Future<void> _togglePlayer() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _listenPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    _audioPlayer.onPlayerComplete.listen((_) => _nextSong());
  }
}

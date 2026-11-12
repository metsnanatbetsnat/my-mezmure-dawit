import 'dart:async';
import 'package:flutter/foundation.dart';

enum AudioPlayerStatus { stopped, playing, paused }
enum AudioRecorderStatus { idle, recording, recorded }

/// Audio service supporting recitation listening and recitation voice practice.
class RecitationAudioService extends ChangeNotifier {
  static final RecitationAudioService _instance = RecitationAudioService._internal();
  factory RecitationAudioService() => _instance;
  RecitationAudioService._internal();

  // Playback state
  AudioPlayerStatus _playerStatus = AudioPlayerStatus.stopped;
  AudioPlayerStatus get playerStatus => _playerStatus;
  bool get isPlaying => _playerStatus == AudioPlayerStatus.playing;
  bool get isPaused => _playerStatus == AudioPlayerStatus.paused;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  int _currentVerseId = 0;
  int get currentVerseId => _currentVerseId;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _totalDuration = const Duration(seconds: 14);
  Duration get totalDuration => _totalDuration;

  Timer? _playbackTimer;
  Timer? _recordTimer;

  // Recording state (for reciting and self-checking)
  AudioRecorderStatus _recorderStatus = AudioRecorderStatus.idle;
  AudioRecorderStatus get recorderStatus => _recorderStatus;
  bool get isRecording => _recorderStatus == AudioRecorderStatus.recording;
  bool get hasRecording => _recorderStatus == AudioRecorderStatus.recorded;

  Duration _recordDuration = Duration.zero;
  Duration get recordDuration => _recordDuration;

  // Play recitation
  void playVerseRecitation(int verseId, {Duration? duration}) {
    if (_playerStatus == AudioPlayerStatus.playing && _currentVerseId == verseId) {
      pauseRecitation();
      return;
    }

    _currentVerseId = verseId;
    _playerStatus = AudioPlayerStatus.playing;
    _totalDuration = duration ?? const Duration(seconds: 12);
    _position = Duration.zero;
    notifyListeners();

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final stepMs = (200 * _playbackSpeed).round();
      _position += Duration(milliseconds: stepMs);
      if (_position >= _totalDuration) {
        stopRecitation();
      } else {
        notifyListeners();
      }
    });
  }

  void pauseRecitation() {
    _playerStatus = AudioPlayerStatus.paused;
    _playbackTimer?.cancel();
    notifyListeners();
  }

  void resumeRecitation() {
    if (_playerStatus == AudioPlayerStatus.paused) {
      _playerStatus = AudioPlayerStatus.playing;
      notifyListeners();

      _playbackTimer?.cancel();
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        final stepMs = (200 * _playbackSpeed).round();
        _position += Duration(milliseconds: stepMs);
        if (_position >= _totalDuration) {
          stopRecitation();
        } else {
          notifyListeners();
        }
      });
    }
  }

  void stopRecitation() {
    _playbackTimer?.cancel();
    _playerStatus = AudioPlayerStatus.stopped;
    _position = Duration.zero;
    notifyListeners();
  }

  void setSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  // --- Voice Recorder Practice ---

  void startRecording() {
    stopRecitation();
    _recorderStatus = AudioRecorderStatus.recording;
    _recordDuration = Duration.zero;
    notifyListeners();

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void stopRecording() {
    _recordTimer?.cancel();
    _recorderStatus = AudioRecorderStatus.recorded;
    notifyListeners();
  }

  void discardRecording() {
    _recordTimer?.cancel();
    _recorderStatus = AudioRecorderStatus.idle;
    _recordDuration = Duration.zero;
    notifyListeners();
  }

  void playRecordedVoice() {
    if (_recordDuration == Duration.zero) return;
    playVerseRecitation(999999, duration: _recordDuration);
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _recordTimer?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Opsiyonel: Daha gelişmiş audio session yönetimi için
// import 'package:audio_session/audio_session.dart';

/// Flutter için kapsamlı ses yönetim sınıfı
/// Bildirim tarzı çalışan, anlık açılıp kapanabilen,
/// kullanıcının farklı sesler arasından seçim yapabildiği,
/// ve diğer sesleri durdurmadan sadece geçici olarak baskılayan (ducking) sistem
class AudioManager {
  static AudioManager? _instance;
  static AudioManager get instance => _instance ??= AudioManager._internal();

  AudioManager._internal();

  // Audio player instance
  AudioPlayer? _audioPlayer;

  // Mevcut ses dosyaları
  final Map<String, String> availableSounds = {
    'rain': 'assets/sounds/rain.mp3',
    'ocean': 'assets/sounds/ocean.wav',
    'forest': 'assets/sounds/forest.wav',
    'white_noise': 'assets/sounds/white_noise.mp3',
    'brown_noise': 'assets/sounds/brown_noise.mp3',
    'pink_noise': 'assets/sounds/pink_noise.mp3',
    'fire': 'assets/sounds/fire.flac',
    'wind': 'assets/sounds/signal.wav',
  };

  // Ses durumu kontrolü
  bool _isPlaying = false;
  bool _isInitialized = false;
  String? _currentSound;
  double _volume = 0.7;

  // Stream controllers for state management
  final StreamController<bool> _playingStateController =
      StreamController<bool>.broadcast();
  final StreamController<String?> _currentSoundController =
      StreamController<String?>.broadcast();
  final StreamController<double> _volumeController =
      StreamController<double>.broadcast();

  // Audio interruption handling
  StreamSubscription? _audioInterruptionSubscription;

  // Getters for streams
  Stream<bool> get playingStateStream => _playingStateController.stream;
  Stream<String?> get currentSoundStream => _currentSoundController.stream;
  Stream<double> get volumeStream => _volumeController.stream;

  // Getters for current state
  bool get isPlaying => _isPlaying;
  String? get currentSound => _currentSound;
  double get volume => _volume;
  List<String> get soundKeys => availableSounds.keys.toList();

  /// AudioManager'ı başlatır
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _audioPlayer = AudioPlayer();

      // Player durumu değişikliklerini dinle
      _audioPlayer!.playingStream.listen((playing) {
        _isPlaying = playing;
        _playingStateController.add(_isPlaying);
      });

      // Ses seviyesi değişikliklerini dinle
      _audioPlayer!.volumeStream.listen((vol) {
        _volume = vol;
        _volumeController.add(_volume);
      });

      // Audio kesintilerini dinle (telefon çalması, bildirimler vs.)
      _setupAudioInterruptionHandling();

      // Kayıtlı tercihleri yükle
      await _loadPreferences();

      _isInitialized = true;
      print('AudioManager initialized successfully');
    } catch (e) {
      print('AudioManager initialization error: $e');
      throw AudioManagerException('Failed to initialize AudioManager: $e');
    }
  }

  /// Audio kesintilerini yönetir (telefon, bildirim vs.)
  void _setupAudioInterruptionHandling() {
    try {
      // just_audio otomatik olarak audio interruption'ları yönetir
      // Ancak manuel kontrol için player events'leri dinleyebiliriz

      _audioPlayer!.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.ready) {
          // Audio hazır
          if (kDebugMode) print('Audio ready for playback');
        }
      });
    } catch (e) {
      print('Error setting up audio interruption handling: $e');
    }
  }

  /// Kayıtlı kullanıcı tercihlerini yükler
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentSound = prefs.getString('selected_sound');
      _volume = prefs.getDouble('volume') ?? 0.7;

      // Stream'leri güncelle
      _currentSoundController.add(_currentSound);
      _volumeController.add(_volume);
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  /// Kullanıcı tercihlerini saklar
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentSound != null) {
        await prefs.setString('selected_sound', _currentSound!);
      }
      await prefs.setDouble('volume', _volume);
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  /// Belirtilen sesi seçer ve kayıtlı tercihi günceller
  Future<void> selectSound(String soundKey) async {
    _ensureInitialized();

    if (!availableSounds.containsKey(soundKey)) {
      throw AudioManagerException('Sound not found: $soundKey');
    }

    try {
      final wasPlaying = _isPlaying;

      // Mevcut sesi durdur
      if (_isPlaying) {
        await stop();
      }

      _currentSound = soundKey;
      _currentSoundController.add(_currentSound);

      // Tercihi kaydet
      await _savePreferences();

      // Eğer daha önce çalıyorsa, yeni sesi çalmaya başla
      if (wasPlaying) {
        await play();
      }
    } catch (e) {
      throw AudioManagerException('Failed to select sound: $e');
    }
  }

  /// Seçili sesi çalmaya başlar
  Future<void> play() async {
    _ensureInitialized();

    if (_currentSound == null) {
      throw AudioManagerException(
        'No sound selected. Please select a sound first.',
      );
    }

    if (_isPlaying) {
      print('Audio is already playing');
      return;
    }

    try {
      final soundPath = availableSounds[_currentSound]!;

      // Audio session'ı yapılandır
      await _configureAdvancedAudioSession();
      final session = await AudioSession.instance;
      await session.setActive(true);

      // Ses dosyasını yükle ve çal
      await _audioPlayer!.setAsset(soundPath);
      await _audioPlayer!.setVolume(_volume);
      await _audioPlayer!.setLoopMode(LoopMode.one);

      await _audioPlayer!.play();

      print('Playing sound: $_currentSound');
    } catch (e) {
      throw AudioManagerException('Failed to play sound: $e');
    }
  }

  /// Sesi durdurur
  Future<void> stop() async {
    _ensureInitialized();

    if (!_isPlaying) {
      print('Audio is not playing');
      return;
    }

    try {
      await _audioPlayer!.stop();
      // Audio session'ı pasif hale getir
      final session = await AudioSession.instance;
      await session.setActive(false); // options parametresi kaldırıldı
      print('Audio stopped');
    } catch (e) {
      throw AudioManagerException('Failed to stop audio: $e');
    }
  }

  /// Sesi geçici olarak duraklatar
  Future<void> pause() async {
    _ensureInitialized();

    if (!_isPlaying) {
      print('Audio is not playing');
      return;
    }

    try {
      await _audioPlayer!.pause();
      print('Audio paused');
    } catch (e) {
      throw AudioManagerException('Failed to pause audio: $e');
    }
  }

  /// Duraklatılmış sesi devam ettirir
  Future<void> resume() async {
    _ensureInitialized();

    try {
      await _audioPlayer!.play();
      print('Audio resumed');
    } catch (e) {
      throw AudioManagerException('Failed to resume audio: $e');
    }
  }

  /// Ses seviyesini ayarlar (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    _ensureInitialized();

    if (volume < 0.0 || volume > 1.0) {
      throw AudioManagerException('Volume must be between 0.0 and 1.0');
    }

    try {
      _volume = volume;
      await _audioPlayer!.setVolume(_volume);
      _volumeController.add(_volume);

      // Tercihi kaydet
      await _savePreferences();
    } catch (e) {
      throw AudioManagerException('Failed to set volume: $e');
    }
  }

  /// Ses seviyesini kademeli olarak artırır/azaltır
  Future<void> fadeVolume(double targetVolume, Duration duration) async {
    _ensureInitialized();

    if (targetVolume < 0.0 || targetVolume > 1.0) {
      throw AudioManagerException('Target volume must be between 0.0 and 1.0');
    }

    try {
      const steps = 20;
      final stepDuration = Duration(
        milliseconds: duration.inMilliseconds ~/ steps,
      );
      final volumeStep = (targetVolume - _volume) / steps;

      for (int i = 0; i < steps; i++) {
        _volume += volumeStep;
        await _audioPlayer!.setVolume(_volume);
        _volumeController.add(_volume);
        await Future.delayed(stepDuration);
      }

      // Son değeri kesin olarak ayarla
      _volume = targetVolume;
      await _audioPlayer!.setVolume(_volume);
      _volumeController.add(_volume);

      // Tercihi kaydet
      await _savePreferences();
    } catch (e) {
      throw AudioManagerException('Failed to fade volume: $e');
    }
  }

  /// Ses dosyası ismini kullanıcı dostu formata çevirir
  String getSoundDisplayName(String soundKey) {
    final displayNames = {
      'rain': '🌧️ Yağmur',
      'ocean': '🌊 Okyanus',
      'forest': '🌲 Orman',
      'white_noise': '⚪ Beyaz Gürültü',
      'brown_noise': '🤎 Kahverengi Gürültü',
      'pink_noise': '🩷 Pembe Gürültü',
      'fire': '🔥 Ateş',
      'wind': '💨 Rüzgar',
    };

    return displayNames[soundKey] ?? soundKey.toUpperCase();
  }

  /// Gelişmiş audio session yönetimi (audio_session paketi gerekli)
  /// Bu metod sadece audio_session paketi yüklüyse çalışır
  Future<void> _configureAdvancedAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
          androidWillPauseWhenDucked: false,
        ),
      );

      // Audio interruption handler'ı ekleyin
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Diğer uygulamalar ses çalarken seviyeyi düşür
              if (_isPlaying) {
                _audioPlayer?.setVolume(_volume * 0.3);
              }
              break;
            case AudioInterruptionType.pause:
            default:
              // Burada herhangi bir işlem yapma (diğer uygulamaları durdurma)
              break;
          }
        } else {
          // Kesinti bittiğinde normal seviyeye dön
          if (_isPlaying) {
            _audioPlayer?.setVolume(_volume);
          }
        }
      });
    } catch (e) {
      print('Advanced audio session configuration error: $e');
    }
  }

  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'isPlaying': _isPlaying,
      'currentSound': _currentSound,
      'currentSoundDisplayName':
          _currentSound != null ? getSoundDisplayName(_currentSound!) : null,
      'volume': _volume,
      'availableSounds': availableSounds.keys.toList(),
    };
  }

  /// Initialization kontrolü
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw AudioManagerException(
        'AudioManager is not initialized. Call initialize() first.',
      );
    }
  }

  /// Kaynakları temizler
  Future<void> dispose() async {
    try {
      await stop();
      await _audioInterruptionSubscription?.cancel();
      await _audioPlayer?.dispose();

      // Audio session'ı temizle
      final session = await AudioSession.instance;
      await session.setActive(false); // options parametresi kaldırıldı

      await _playingStateController.close();
      await _currentSoundController.close();
      await _volumeController.close();

      _isInitialized = false;
      _instance = null;

      print('AudioManager disposed');
    } catch (e) {
      print('Error disposing AudioManager: $e');
    }
  }
}

/// AudioManager için özel exception sınıfı
class AudioManagerException implements Exception {
  final String message;
  AudioManagerException(this.message);

  @override
  String toString() => 'AudioManagerException: $message';
}

/// AudioManager kullanımı için yardımcı mixin
mixin AudioManagerMixin {
  AudioManager get audioManager => AudioManager.instance;

  /// Widget'ın dispose edilmesi sırasında AudioManager'ı temizler
  void disposeAudioManager() {
    // Bu metod sadece uygulamanın tamamen kapanması sırasında çağrılmalı
    // Normal widget dispose işlemlerinde çağrılmamalı
  }
}

/// Kullanım örneği için model sınıfı
class SoundOption {
  final String key;
  final String displayName;
  final String assetPath;
  final bool isSelected;

  SoundOption({
    required this.key,
    required this.displayName,
    required this.assetPath,
    this.isSelected = false,
  });

  factory SoundOption.fromManager(String key, AudioManager manager) {
    return SoundOption(
      key: key,
      displayName: manager.getSoundDisplayName(key),
      assetPath: manager.availableSounds[key]!,
      isSelected: manager.currentSound == key,
    );
  }
}

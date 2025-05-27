
# Türkçe Versiyon

```markdown
# Flutter için Ses Yöneticisi

[![pub paket](https://img.shields.io/pub/v/audio_manager.svg)](https://pub.dev/packages/audio_manager)
[![lisans](https://img.shields.io/badge/lisans-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Flutter uygulamaları için kapsamlı bir ses yönetim çözümü, arka planda ses çalma özelliği ve uygun ses oturum yönetimi sunar.

## Özellikler

- 🎵 Arka planda ses çalma
- 🔊 Ses kısma (diğer uygulamalar ses çalarken otomatik alçaltma)
- ⏯️ Oynat, duraklat, durdur kontrolleri
- 🔉 Ses seviyesi ayarı ve kademeli değiştirme
- 🔄 Çoklu ses ön ayarları
- 📱 Android ve iOS desteği
- 🔄 SharedPreferences ile kalıcı ayarlar
- 🎚️ Ses oturum yönetimi

## Kurulum

`pubspec.yaml` dosyanıza ekleyin:

```yaml
dependencies:
  just_audio: ^0.10.3
  audio_session: ^0.2.2
  shared_preferences: ^2.5.3

# English Version

# Audio Manager for Flutter

[![pub package](https://img.shields.io/pub/v/audio_manager.svg)](https://pub.dev/packages/audio_manager)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A comprehensive audio management solution for Flutter applications, providing background audio playback with proper audio session management and ducking support.

## Features

- 🎵 Background audio playback
- 🔊 Audio ducking (lowers volume when other apps play sound)
- ⏯️ Play, pause, stop controls
- 🔉 Volume adjustment and fading
- 🔄 Multiple sound presets
- 📱 Works on both Android and iOS
- 🔄 Persistent settings with SharedPreferences
- 🎚️ Audio session management

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  just_audio: ^0.10.3
  audio_session: ^0.2.2
  shared_preferences: ^2.5.3

## Usage
// Initialize
await AudioManager.instance.initialize();

// Play sound
await AudioManager.instance.selectSound('rain');
await AudioManager.instance.play();

// Adjust volume
await AudioManager.instance.setVolume(0.8);

// Fade volume
await AudioManager.instance.fadeVolume(0.3, Duration(seconds: 2));

// Pause/Resume
await AudioManager.instance.pause();
await AudioManager.instance.resume();

// Stop
await AudioManager.instance.stop();

## Configuration

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager.instance.initialize();
  runApp(MyApp());
}

## License
This project is licensed under the MIT License - see the LICENSE file for details.


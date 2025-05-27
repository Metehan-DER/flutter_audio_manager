

````markdown
# 🎧 Flutter Ses Yöneticisi (Audio Manager)

[![Pub Versiyonu](https://img.shields.io/pub/v/audio_manager.svg)](https://pub.dev/packages/audio_manager)
[![Lisans](https://img.shields.io/badge/Lisans-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Flutter uygulamaları için kapsamlı ve kullanıcı dostu bir ses yönetim çözümüdür. Arka planda ses çalma, **ducking** (diğer uygulamalar ses çaldığında sesin otomatik olarak azaltılması) ve **kalıcı kullanıcı tercihleri** gibi özellikler sunar.

---

## 🚀 Özellikler

- 🎵 Arka planda ses çalma
- 🔊 Diğer uygulamalar ses çaldığında sesi otomatik düşürme (ducking)
- ⏯️ Oynat / Duraklat / Durdur kontrolleri
- 🔉 Anlık veya kademeli ses seviyesi ayarı
- 🔄 Hazır ses ön ayarları (örneğin: yağmur, orman, beyaz gürültü)
- 📱 Android ve iOS desteği
- 💾 Kalıcı ayarlar için `SharedPreferences` entegrasyonu
- 🎚️ `AudioSession` ile gelişmiş ses oturum yönetimi

---

## 📦 Kurulum

`pubspec.yaml` dosyanıza aşağıdaki bağımlılıkları ekleyin:

```yaml
dependencies:
  just_audio: ^0.10.3
  audio_session: ^0.2.2
  shared_preferences: ^2.0.15
````

---

## 🛠️ Kullanım

```dart
// Başlat
await AudioManager.instance.initialize();

// Ses seç ve çal
await AudioManager.instance.selectSound('rain');
await AudioManager.instance.play();

// Sesi değiştir
await AudioManager.instance.setVolume(0.8);

// Kademeli ses azalt
await AudioManager.instance.fadeVolume(0.3, Duration(seconds: 2));

// Duraklat / Devam ettir
await AudioManager.instance.pause();
await AudioManager.instance.resume();

// Durdur
await AudioManager.instance.stop();
```

---

## ⚙️ Başlatma (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager.instance.initialize();
  runApp(MyApp());
}
```

---

## 📄 Lisans

Bu proje [MIT Lisansı](https://opensource.org/licenses/MIT) ile lisanslanmıştır.

---

---

# 🎧 Audio Manager for Flutter

[![Pub Version](https://img.shields.io/pub/v/audio_manager.svg)](https://pub.dev/packages/audio_manager)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful and user-friendly audio management solution for Flutter applications. It provides background audio playback, ducking support when other apps play audio, and persistent user preferences.

---

## 🚀 Features

* 🎵 Background audio playback
* 🔊 Automatic volume ducking when other apps play audio
* ⏯️ Play / Pause / Stop controls
* 🔉 Volume control with optional fading
* 🔄 Built-in sound presets (e.g., rain, forest, white noise)
* 📱 Cross-platform support (Android & iOS)
* 💾 Persistent preferences via `SharedPreferences`
* 🎚️ Smart session management with `audio_session`

---

## 📦 Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  just_audio: ^0.10.3
  audio_session: ^0.2.2
  shared_preferences: ^2.0.15
```

---

## 🛠️ Usage

```dart
// Initialize
await AudioManager.instance.initialize();

// Select and play a sound
await AudioManager.instance.selectSound('rain');
await AudioManager.instance.play();

// Adjust volume
await AudioManager.instance.setVolume(0.8);

// Fade volume smoothly
await AudioManager.instance.fadeVolume(0.3, Duration(seconds: 2));

// Pause and resume
await AudioManager.instance.pause();
await AudioManager.instance.resume();

// Stop playback
await AudioManager.instance.stop();
```

---

## ⚙️ Entry Point (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager.instance.initialize();
  runApp(MyApp());
}
```

---

## 📄 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

```


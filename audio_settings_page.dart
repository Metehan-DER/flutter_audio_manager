import 'package:flutter/material.dart';
import 'package:untitled1/services/audio_service.dart';

class AudioSettingsPage extends StatefulWidget {
  const AudioSettingsPage({super.key});

  @override
  State<AudioSettingsPage> createState() => _AudioSettingsPageState();
}

class _AudioSettingsPageState extends State<AudioSettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;
  final AudioManager audioManager = AudioManager.instance;

  @override
  void initState() {
    super.initState();
    _initializeAudioManager();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeAudioManager() async {
    setState(() => _isLoading = true);
    try {
      await audioManager.initialize();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Audio manager error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    // Don't dispose audioManager here as it's a singleton
    super.dispose();
  }

  // Ses seçimi
  Future<void> _handleSoundSelect(String soundKey) async {
    setState(() => _isLoading = true);
    try {
      await audioManager.selectSound(soundKey);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ses seçimi hatası: $error')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Oynatma kontrolü
  Future<void> _handlePlayPause() async {
    try {
      if (audioManager.isPlaying) {
        await audioManager.stop();
      } else {
        await audioManager.play();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oynatma kontrolü hatası: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Ses seviyesi ayarı
  Future<void> _handleVolumeChange(double newVolume) async {
    try {
      await audioManager.setVolume(newVolume);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ses seviyesi ayarlama hatası: $error')),
      );
    }
  }

  // Ses seviyesi fade efekti
  Future<void> _handleVolumeFade(double targetVolume) async {
    try {
      await audioManager.fadeVolume(targetVolume, Duration(seconds: 2));
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Volume fade hatası: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // slate-900
              Color(0xFF581C87), // purple-900
              Color(0xFF0F172A), // slate-900
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildPlaybackControl(),
                const SizedBox(height: 24),
                _buildSoundSelection(),
                const SizedBox(height: 24),
                _buildVolumeControl(),
                const SizedBox(height: 24),
                _buildSystemStatus(),
                const SizedBox(height: 32),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: const Icon(Icons.settings, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ses Ayarları',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Cihaz seslerini yönetin',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControl() {
    return StreamBuilder<bool>(
      stream: audioManager.playingStateStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6).withOpacity(0.1),
                const Color(0xFF9333EA).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: StreamBuilder<String?>(
                      stream: audioManager.currentSoundStream,
                      builder: (context, snapshot) {
                        final currentSound = snapshot.data;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Şu An Çalıyor',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentSound != null
                                  ? audioManager.getSoundDisplayName(
                                    currentSound,
                                  )
                                  : 'Ses seçilmedi',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap:
                            audioManager.currentSound != null && !_isLoading
                                ? _handlePlayPause
                                : null,
                        child: Center(
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              isPlaying
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFF64748B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        transform:
                            Matrix4.identity()
                              ..scale(isPlaying ? _pulseAnimation.value : 1.0),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPlaying ? 'Çalıyor' : 'Durduruldu',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoundSelection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ses Seçimi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: audioManager.soundKeys.length,
            itemBuilder: (context, index) {
              final key = audioManager.soundKeys[index];
              final displayName = audioManager.getSoundDisplayName(key);
              final isSelected = audioManager.currentSound == key;

              return Container(
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFF3B82F6).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF60A5FA)
                            : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isLoading ? null : () => _handleSoundSelect(key),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: Color(0xFF60A5FA),
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl() {
    return StreamBuilder<double>(
      stream: audioManager.volumeStream,
      builder: (context, snapshot) {
        final volume = snapshot.data ?? 0.7;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ses Seviyesi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        volume == 0 ? Icons.volume_off : Icons.volume_up,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(volume * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFCBD5E1),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF3B82F6),
                  inactiveTrackColor: const Color(0xFF334155),
                  thumbColor: const Color(0xFF3B82F6),
                  overlayColor: const Color(0xFF3B82F6).withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  trackHeight: 8,
                ),
                child: Slider(
                  value: volume,
                  onChanged: _handleVolumeChange,
                  min: 0,
                  max: 1,
                  divisions: 100,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children:
                    [0.25, 0.5, 0.75, 1.0].map((level) {
                      final isActive = (volume - level).abs() < 0.05;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? const Color(0xFF3B82F6)
                                      : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => _handleVolumeFade(level),
                                child: Center(
                                  child: Text(
                                    '${(level * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isActive
                                              ? Colors.white
                                              : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSystemStatus() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
      ).asyncMap((_) => audioManager.getStatus()),
      builder: (context, snapshot) {
        final status = snapshot.data ?? {};

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sistem Durumu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusRow(
                'Başlatıldı',
                status['isInitialized'] == true ? 'Aktif' : 'Başlatılıyor',
                status['isInitialized'] == true
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFF59E0B),
              ),
              _buildStatusRow(
                'Seçili Ses',
                status['currentSoundDisplayName'] ?? 'Yok',
                Colors.white,
              ),
              _buildStatusRow(
                'Oynatma Durumu',
                status['isPlaying'] == true ? 'Çalıyor' : 'Durduruldu',
                status['isPlaying'] == true
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFF94A3B8),
              ),
              _buildStatusRow(
                'Audio Focus',
                'Ducking Aktif',
                const Color(0xFF60A5FA),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label == 'Başlatıldı')
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: valueColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              Text(value, style: TextStyle(fontSize: 14, color: valueColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text(
        'Sesler diğer medya uygulamalarını durdurmaz, sadece ses seviyelerini ayarlar',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
    );
  }
}

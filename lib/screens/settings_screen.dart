import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final presets = audioProvider.eqPresets.keys.toList();
    final safePreset = presets.contains(audioProvider.currentPreset)
        ? audioProvider.currentPreset
        : presets.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Volume'),
            Slider(
              value: audioProvider.volume.clamp(0.0, 1.0),
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: AppColors.primary,
              inactiveColor: Colors.grey[700],
              onChanged: audioProvider.setVolume,
            ),

            const SizedBox(height: 24),
            _sectionTitle('Playback Speed'),
            Slider(
              value: audioProvider.speed.clamp(0.5, 2.0),
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: '${audioProvider.speed.toStringAsFixed(1)}x',
              activeColor: AppColors.primary,
              inactiveColor: Colors.grey[700],
              onChanged: audioProvider.setSpeed,
            ),

            const SizedBox(height: 32),
            _sectionTitle('Playback Mode'),
            Row(
              children: [
                Chip(
                  label: Text(
                    audioProvider.isShuffleEnabled
                        ? 'Shuffle: ON'
                        : 'Shuffle: OFF',
                  ),
                  backgroundColor: audioProvider.isShuffleEnabled
                      ? AppColors.primary
                      : AppColors.card,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_repeatLabel(audioProvider.loopMode)),
                  backgroundColor: AppColors.card,
                ),
              ],
            ),

            const SizedBox(height: 32),
            _sectionTitle('Equalizer'),

            DropdownButtonFormField<String>(
              dropdownColor: AppColors.card,
              value: safePreset,
              isExpanded: true,
              decoration: _inputDecoration(),
              items: presets
                  .map(
                    (preset) => DropdownMenuItem(
                      value: preset,
                      child: Text(
                        preset,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  audioProvider.setPreset(value);
                }
              },
            ),

            const SizedBox(height: 16),

            const Text(
              'Custom Equalizer',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),

            ...List.generate(
              audioProvider.customEQ.length.clamp(0, 5),
              (i) => _eqSlider(
                audioProvider,
                i,
                _bandLabel(i),
              ),
            ),

            const SizedBox(height: 32),
            _sectionTitle('Audio Enhancements'),

            SwitchListTile(
              value: audioProvider.currentPreset == 'Bass Boost',
              activeColor: AppColors.primary,
              title: const Text(
                'Bass Boost',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Enhance low frequencies',
                style: TextStyle(color: Colors.grey),
              ),
              onChanged: (enabled) {
                audioProvider.setPreset(
                  enabled ? 'Bass Boost' : 'Flat', 
                );
              },
            ),

            SwitchListTile(
              value: false,
              activeColor: AppColors.primary,
              title: const Text(
                'Virtualizer',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Simulate surround sound (UI ready)',
                style: TextStyle(color: Colors.grey),
              ),
              onChanged: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Virtualizer will be supported later'),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            _sectionTitle('Sleep Timer'),

            Wrap(
              spacing: 8,
              children: [
                _timerButton(context, audioProvider, 15),
                _timerButton(context, audioProvider, 30),
                _timerButton(context, audioProvider, 60),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                audioProvider.cancelSleepTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sleep timer cancelled'),
                  ),
                );
              },
              child: const Text('Cancel sleep timer'),
            ),

            const SizedBox(height: 32),
            _sectionTitle('About'),
            const Text(
              'Offline Music Player\n'
              'Built with Flutter\n',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(),
    );
  }

  Widget _timerButton(
    BuildContext context,
    AudioProvider provider,
    int minutes,
  ) {
    return ElevatedButton(
      onPressed: () {
        provider.startSleepTimer(Duration(minutes: minutes));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sleep timer set: $minutes minutes'),
          ),
        );
      },
      child: Text('$minutes min'),
    );
  }

  Widget _eqSlider(
    AudioProvider provider,
    int index,
    String label,
  ) {
    final value = provider.customEQ[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Slider(
          value: value.clamp(-10.0, 10.0),
          min: -10,
          max: 10,
          divisions: 20,
          label: value.toStringAsFixed(0),
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey[700],
          onChanged: (v) => provider.setCustomBand(index, v),
        ),
      ],
    );
  }

  String _bandLabel(int index) {
    const labels = ['60 Hz', '230 Hz', '910 Hz', '3.6 kHz', '14 kHz'];
    return index < labels.length ? labels[index] : 'Band';
  }

  String _repeatLabel(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return 'Repeat: OFF';
      case LoopMode.all:
        return 'Repeat: ALL';
      case LoopMode.one:
        return 'Repeat: ONE';
    }
  }
}

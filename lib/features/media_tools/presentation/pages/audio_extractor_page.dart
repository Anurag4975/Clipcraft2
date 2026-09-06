import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import '../../../../app/theme/app_theme.dart';
import '../../../../app/di/injection_container.dart';
import '../../domain/usecases/extract_audio.dart';

class AudioExtractorPage extends StatefulWidget {
  const AudioExtractorPage({super.key});

  @override
  State<AudioExtractorPage> createState() => _AudioExtractorPageState();
}

class _AudioExtractorPageState extends State<AudioExtractorPage> {
  String? _selectedVideoPath;
  String? _extractedAudioPath;
  bool _isProcessing = false;
  AudioFormat _format = AudioFormat.mp3;

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result?.files.single.path != null) {
      setState(() {
        _selectedVideoPath = result!.files.single.path;
        _extractedAudioPath = null;
      });
    }
  }

  Future<void> _extract() async {
    if (_selectedVideoPath == null) return;
    setState(() => _isProcessing = true);

    final extractAudio = getIt<ExtractAudio>();
    final result = await extractAudio(
      ExtractAudioParams(videoPath: _selectedVideoPath!, format: _format),
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${failure.message}')),
          );
        }
      },
      (audioPath) {
        if (mounted) setState(() => _extractedAudioPath = audioPath);
      },
    );

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Audio Extractor')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_file_rounded),
              label: Text(_selectedVideoPath == null
                  ? 'Select Video'
                  : path.basename(_selectedVideoPath!)),
            ),
            const SizedBox(height: 16),
            SegmentedButton<AudioFormat>(
              segments: const [
                ButtonSegment(value: AudioFormat.mp3, label: Text('MP3')),
                ButtonSegment(value: AudioFormat.wav, label: Text('WAV')),
              ],
              selected: {_format},
              onSelectionChanged: (s) => setState(() => _format = s.first),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selectedVideoPath != null && !_isProcessing
                  ? _extract
                  : null,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.audiotrack_rounded),
              label: Text(_isProcessing ? 'Extracting...' : 'Extract Audio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
            if (_extractedAudioPath != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Extracted successfully',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_extractedAudioPath!,
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:whisper_ggml_plus/whisper_ggml_plus.dart';

class WhisperModelOption {
  final WhisperModel model;
  final String label;
  final String approxSize;
  final bool recommended;

  const WhisperModelOption({
    required this.model,
    required this.label,
    required this.approxSize,
    this.recommended = false,
  });
}

/// Manages which on-device Whisper model the user has selected/downloaded.
/// NOTE: whisper_ggml_plus appears to handle model loading (and likely
/// downloading) internally when transcribe() is first called for a given
/// model — there's no confirmed separate "download only" API as of writing.
/// This class is a thin wrapper so the rest of the app doesn't care how
/// that resolves; if the package DOES expose an explicit download/progress
/// API, wire it into `ensureModelReady` below once confirmed.
class ModelManager {
  static const List<WhisperModelOption> availableModels = [
    WhisperModelOption(
        model: WhisperModel.tiny, label: 'Tiny', approxSize: '~75 MB'),
    WhisperModelOption(
        model: WhisperModel.base, label: 'Base', approxSize: '~140 MB'),
    WhisperModelOption(
        model: WhisperModel.small, label: 'Small', approxSize: '~460 MB'),
    WhisperModelOption(
        model: WhisperModel.medium, label: 'Medium', approxSize: '~1.5 GB'),
    WhisperModelOption(
      model: WhisperModel.largeV3Turbo,
      label: 'Large v3 Turbo',
      approxSize: '~1.6 GB',
      recommended: true,
    ),
  ];

  /// Best-effort "is this model ready to use" check. Since we can't confirm
  /// a dedicated status API, this currently just returns true and lets
  /// transcribe() handle loading/downloading on first real use — the UI
  /// should show a loading state during the FIRST transcription with a
  /// given model, since that's likely when any download happens.
  Future<bool> isModelReady(WhisperModel model) async {
    // TODO: replace with a real check once the package's API is confirmed,
    // e.g. controller.isModelDownloaded(model) or similar.
    return true;
  }
}

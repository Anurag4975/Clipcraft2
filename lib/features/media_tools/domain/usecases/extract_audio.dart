import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/ffmpeg_service.dart';

enum AudioFormat { wav, mp3 }

class ExtractAudioParams {
  final String videoPath;
  final AudioFormat format;
  const ExtractAudioParams(
      {required this.videoPath, this.format = AudioFormat.mp3});
}

/// Standalone usecase — lets a user extract audio from any video
/// independent of the Projects/AI-clip feature entirely.
class ExtractAudio {
  final FFmpegService _ffmpegService;
  ExtractAudio(this._ffmpegService);

  Future<Either<Failure, String>> call(ExtractAudioParams params) async {
    try {
      final outputPath = params.format == AudioFormat.wav
          ? await _ffmpegService.extractAudioAsWav(params.videoPath)
          : await _ffmpegService.extractAudioAsMp3(params.videoPath);
      return Right(outputPath);
    } catch (e) {
      return Left(CacheFailure('Audio extraction failed: $e'));
    }
  }
}

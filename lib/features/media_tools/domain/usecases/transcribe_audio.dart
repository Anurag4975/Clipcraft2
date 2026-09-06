import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/transcription_service.dart';

class TranscribeAudio {
  final TranscriptionService _transcriptionService;
  TranscribeAudio(this._transcriptionService);

  Future<Either<Failure, Transcript>> call(String wavPath) async {
    try {
      final transcript = await _transcriptionService.transcribe(wavPath);
      return Right(transcript);
    } catch (e) {
      return Left(CacheFailure('Transcription failed: $e'));
    }
  }
}

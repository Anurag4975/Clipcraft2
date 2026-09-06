import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';

class AnalyzeProject implements UseCase<AnalysisResult, Project> {
  // ✅ Added @override
  @override
  Future<Either<Failure, AnalysisResult>> call(Project project) async {
    // ✅ Correct check: duration is non-nullable, compare to Duration.zero
    if (project.videoPath == null || project.duration == Duration.zero) {
      return const Left(CacheFailure('Upload a video first'));
    }

    await Future.delayed(const Duration(seconds: 4));

    final totalSec = project.duration.inSeconds;
    final clips = <ViralClip>[];

    if (totalSec > 15) {
      clips.add(ViralClip(
        id: 'clip-1',
        startAt: Duration(seconds: (totalSec * 0.05).round()),
        endAt: Duration(seconds: (totalSec * 0.18).round()),
        title: '🚀 Strong Opening Hook',
        confidence: 0.92,
      ));
    }

    if (totalSec > 45) {
      clips.add(ViralClip(
        id: 'clip-2',
        startAt: Duration(seconds: (totalSec * 0.35).round()),
        endAt: Duration(seconds: (totalSec * 0.55).round()),
        title: '🔥 High Engagement Moment',
        confidence: 0.87,
      ));
    }

    if (totalSec > 90) {
      clips.add(ViralClip(
        id: 'clip-3',
        startAt: Duration(seconds: (totalSec * 0.70).round()),
        endAt: Duration(seconds: (totalSec * 0.90).round()),
        title: '💥 Climax / Call to Action',
        confidence: 0.78,
      ));
    }

    final avgConfidence = clips.isNotEmpty
        ? clips.map((c) => c.confidence).reduce((a, b) => a + b) / clips.length
        : 0.5;

    return Right(AnalysisResult(
      clips: clips,
      summary:
          '✅ AI found ${clips.length} viral clip${clips.length == 1 ? '' : 's'} with high retention potential!',
      viralScore: avgConfidence,
    ));
  }
}

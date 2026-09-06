import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';

class ExportSelectedClips implements UseCase<String, Project> {
  @override
  Future<Either<Failure, String>> call(Project project) async {
    if (project.videoPath == null) {
      return const Left(CacheFailure('Upload a video first'));
    }
    final clips = project.selectedViralClips;
    if (clips.isEmpty) {
      return const Left(CacheFailure('Select at least one clip to export'));
    }

    final videoFile = File(project.videoPath!);
    if (!await videoFile.exists()) {
      return Left(CacheFailure('Video file not found: ${project.videoPath}'));
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${appDir.path}/ClipCraft/Exports');
      if (!await exportDir.exists()) await exportDir.create(recursive: true);

      final outputPath = path.join(
        exportDir.path,
        '${project.name.replaceAll(' ', '_')}_export_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      final filterParts = <String>[];
      final streamLabels = <String>[]; // ✅ was missing — needed for concat

      for (var i = 0; i < clips.length; i++) {
        final clip = clips[i];
        final start = clip.startAt.inSeconds;
        final end = clip.endAt.inSeconds;
        filterParts.add('[0:v]trim=$start:$end,setpts=PTS-STARTPTS[v$i];');
        // ✅ audio trim uses "atrim", not "trim"
        filterParts.add('[0:a]atrim=$start:$end,asetpts=PTS-STARTPTS[a$i];');
        streamLabels.add('[v$i][a$i]'); // ✅ fixed: was invalid '[$v$i]'
      }

      final filterComplex = filterParts.join() +
          streamLabels.join() +
          'concat=n=${clips.length}:v=1:a=1[outv][outa]';

      final command =
          '-i "${project.videoPath}" -filter_complex "$filterComplex" '
          '-map "[outv]" -map "[outa]" -c:v libx264 -c:a aac "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return Right(outputPath);
      } else {
        final logs = await session.getLogsAsString();
        return Left(CacheFailure('Export failed: $logs'));
      }
    } catch (e) {
      return Left(CacheFailure('Export error: $e'));
    }
  }
}

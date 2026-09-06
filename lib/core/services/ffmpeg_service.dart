import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';

/// Central place for all FFmpeg operations. Any feature (audio tools,
/// AI clip pipeline, future timeline editor) should go through this
/// service instead of building its own FFmpeg commands.
class FFmpegService {
  /// Extracts audio from a video file as a standalone WAV (16kHz mono —
  /// the format Whisper expects). Returns the output file path.
  Future<String> extractAudioAsWav(String videoPath,
      {String? outputDir}) async {
    final dir = outputDir ?? (await _defaultOutputDir('Audio'));
    final outputPath = path.join(
      dir,
      '${path.basenameWithoutExtension(videoPath)}_${DateTime.now().millisecondsSinceEpoch}.wav',
    );

    final command =
        '-i "$videoPath" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    } else {
      final logs = await session.getLogsAsString();
      throw FFmpegException('Audio extraction failed: $logs');
    }
  }

  /// Extracts audio as a compressed MP3 (smaller file, good for sharing
  /// or export — NOT for feeding to Whisper, use extractAudioAsWav for that).
  Future<String> extractAudioAsMp3(String videoPath,
      {String? outputDir}) async {
    final dir = outputDir ?? (await _defaultOutputDir('Audio'));
    final outputPath = path.join(
      dir,
      '${path.basenameWithoutExtension(videoPath)}_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    final command =
        '-i "$videoPath" -vn -acodec libmp3lame -q:a 2 "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    } else {
      final logs = await session.getLogsAsString();
      throw FFmpegException('Audio extraction failed: $logs');
    }
  }

  /// Trims and concatenates a list of (start, end) ranges from one video
  /// into a single output file. Used by the clip export flow.
  Future<String> trimAndMergeClips(
    String videoPath,
    List<({Duration start, Duration end})> ranges,
    String outputPath,
  ) async {
    final filterParts = <String>[];
    final streamLabels = <String>[];

    for (var i = 0; i < ranges.length; i++) {
      final start = ranges[i].start.inSeconds;
      final end = ranges[i].end.inSeconds;
      filterParts.add('[0:v]trim=$start:$end,setpts=PTS-STARTPTS[v$i];');
      filterParts.add('[0:a]atrim=$start:$end,asetpts=PTS-STARTPTS[a$i];');
      streamLabels.add('[v$i][a$i]');
    }

    final filterComplex = filterParts.join() +
        streamLabels.join() +
        'concat=n=${ranges.length}:v=1:a=1[outv][outa]';

    final command = '-i "$videoPath" -filter_complex "$filterComplex" '
        '-map "[outv]" -map "[outa]" -c:v libx264 -c:a aac "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    } else {
      final logs = await session.getLogsAsString();
      throw FFmpegException('Trim/merge failed: $logs');
    }
  }

  /// Reads media duration using ffprobe — handy for validating files
  /// independent of video_player, e.g. for non-video audio-only tools.
  Future<Duration?> getDuration(String filePath) async {
    final session = await FFprobeKit.getMediaInformation(filePath);
    final info = session.getMediaInformation();
    final durationStr = info?.getDuration();
    if (durationStr == null) return null;
    final seconds = double.tryParse(durationStr);
    if (seconds == null) return null;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  Future<String> _defaultOutputDir(String subfolder) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/ClipCraft/$subfolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }
}

class FFmpegException implements Exception {
  final String message;
  FFmpegException(this.message);
  @override
  String toString() => message;
}

import 'package:whisper_ggml_plus/whisper_ggml_plus.dart';

class TranscriptSegment {
  final Duration start;
  final Duration end;
  final String text;
  const TranscriptSegment(
      {required this.start, required this.end, required this.text});
}

class Transcript {
  final String fullText;
  final List<TranscriptSegment> segments;
  const Transcript({required this.fullText, required this.segments});

  String toTimestampedString() {
    final buffer = StringBuffer();
    for (final s in segments) {
      buffer.writeln('[${_fmt(s.start)} -> ${_fmt(s.end)}] ${s.text.trim()}');
    }
    return buffer.toString();
  }

  String _fmt(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}

class TranscriptionService {
  final WhisperController _controller = WhisperController();

  Future<Transcript> transcribe(String wavPath,
      {WhisperModel model = WhisperModel.largeV3Turbo}) async {
    dynamic result;
    try {
      result = await _controller.transcribe(
        model: model,
        audioPath: wavPath,
        lang: 'auto',
        withTimestamps: true,
      );
    } catch (e) {
      // Surface the raw error clearly — if the method signature is wrong
      // (wrong param names, missing named args, etc.) this is where
      // you'll see it. Paste this error back and I'll fix the call.
      throw TranscriptionException('Whisper transcribe() call failed: $e');
    }

    if (result == null) {
      throw TranscriptionException(
          'Whisper returned null — check model download/load succeeded.');
    }

    // Defensive extraction: if field names differ from what I assumed,
    // this throws a clear error naming the missing field instead of a
    // vague NoSuchMethodError.
    List<TranscriptSegment> segments = [];
    String fullText = '';
    try {
      final transcription = result.transcription;
      fullText = transcription.text as String;
      final rawSegments = transcription.segments as List;
      segments = rawSegments.map<TranscriptSegment>((seg) {
        final fromTs = seg.fromTs;
        final toTs = seg.toTs;
        final text = seg.text as String;
        // fromTs/toTs unit is unconfirmed — could be ms or centiseconds.
        // Log both interpretations so you can tell which looks right:
        // print('fromTs raw value: $fromTs');
        return TranscriptSegment(
          start: Duration(milliseconds: fromTs as int),
          end: Duration(milliseconds: toTs as int),
          text: text,
        );
      }).toList();
    } catch (e) {
      throw TranscriptionException(
        'Result shape did not match expectations (field access failed: $e). '
        'Run debugPrint(result.runtimeType) and debugPrint(result.toString()) '
        'to inspect the actual shape, then report back.',
      );
    }

    return Transcript(fullText: fullText, segments: segments);
  }
}

class TranscriptionException implements Exception {
  final String message;
  TranscriptionException(this.message);
  @override
  String toString() => message;
}

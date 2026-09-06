import 'package:equatable/equatable.dart';

class AnalysisResult extends Equatable {
  final double viralScore;
  final String summary;
  final List<ClipSuggestion> clips;

  const AnalysisResult({
    required this.viralScore,
    required this.summary,
    required this.clips,
  });

  @override
  List<Object?> get props => [viralScore, summary, clips];
}

class ClipSuggestion extends Equatable {
  final String title;
  final Duration startAt;
  final Duration endAt;
  final double confidence;

  const ClipSuggestion({
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.confidence,
  });

  @override
  List<Object?> get props => [title, startAt, endAt, confidence];
}

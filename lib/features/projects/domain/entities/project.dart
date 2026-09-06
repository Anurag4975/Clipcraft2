import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

// YOUR ACTUAL ENUM
enum ProjectStatus { editing, analyzing, ready, exporting }

// 🎬 Detected Viral Clip
class ViralClip extends Equatable {
  final String id;
  final Duration startAt;
  final Duration endAt;
  final String title;
  final double confidence;

  const ViralClip({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.title,
    required this.confidence,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'startAtSec': startAt.inSeconds,
        'endAtSec': endAt.inSeconds,
        'title': title,
        'confidence': confidence,
      };

  factory ViralClip.fromMap(Map<String, dynamic> map) => ViralClip(
        id: map['id'] as String,
        startAt: Duration(seconds: map['startAtSec'] as int),
        endAt: Duration(seconds: map['endAtSec'] as int),
        title: map['title'] as String,
        confidence: (map['confidence'] as num).toDouble(),
      );

  @override
  List<Object?> get props => [id, startAt, endAt, title, confidence];
}

// 📊 Analysis Result
class AnalysisResult {
  final List<ViralClip> clips;
  final String summary;
  final double viralScore;

  const AnalysisResult({
    required this.clips,
    required this.summary,
    required this.viralScore,
  });
}

@HiveType(typeId: 0)
class Project extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final String? videoPath;

  @HiveField(4)
  final Duration duration;

  @HiveField(5)
  final ProjectStatus status;

  @HiveField(6)
  final DateTime? lastEdited;

  @HiveField(7)
  final int clipsCount;

  @HiveField(8)
  final List<Map> clipsData;

  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    this.videoPath,
    this.duration = Duration.zero,
    this.status = ProjectStatus.editing,
    this.lastEdited,
    this.clipsCount = 0,
    this.clipsData = const [],
  });

  // ✅ FIXED: Added videoPath parameter
  factory Project.create({required String name, String? videoPath}) {
    return Project(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      videoPath: videoPath,
    );
  }

  // ✅ Helper: Get typed ViralClip list
  List<ViralClip> get clips => clipsData
      .map((m) => ViralClip.fromMap(Map<String, dynamic>.from(m)))
      .toList();

  // ✅ FIXED: Added formattedDuration getter
  String get formattedDuration {
    if (duration == Duration.zero) return '--:--';
    final mins = duration.inMinutes.toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  // ✅ FIXED: Added relativeDate getter
  String get relativeDate {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        createdAt,
        videoPath,
        duration,
        status,
        lastEdited,
        clipsCount,
        clipsData,
      ];
}

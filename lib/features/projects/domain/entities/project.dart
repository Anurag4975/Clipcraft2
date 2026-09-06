import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

// ✅ YOUR ACTUAL ENUM — matches your codebase
enum ProjectStatus { editing, analyzing, ready, exporting }

// 🎬 Detected Viral Clip — standalone class
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
  final Duration duration; // ✅ Non-nullable, defaults to Duration.zero

  @HiveField(5)
  final ProjectStatus status;

  @HiveField(6)
  final DateTime? lastEdited;

  @HiveField(7)
  final int clipsCount;

  // ✅ NEW: Store clips as List<Map> — Hive handles primitives easily
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

  // ✅ Helper: Create new project
  factory Project.create({required String name}) {
    return Project(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
    );
  }

  // ✅ Helper: Get typed ViralClip list from raw maps
  List<ViralClip> get clips => clipsData
      .map((m) => ViralClip.fromMap(Map<String, dynamic>.from(m)))
      .toList();

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

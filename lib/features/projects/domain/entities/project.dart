import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'viral_clip.dart';

enum ProjectStatus { editing, analyzing, ready, exporting }

class Project extends Equatable {
  final String id;
  final String name;
  final String? videoPath;
  final Duration duration;
  final DateTime createdAt;
  final DateTime? lastEdited;
  final ProjectStatus status;
  final int clipsCount;
  final List<Map<String, dynamic>> clips;
  final List<String> selectedClipIds; // ✅ new
  final String? exportedVideoPath; // ✅ new

  const Project({
    required this.id,
    required this.name,
    this.videoPath,
    this.duration = Duration.zero,
    required this.createdAt,
    this.lastEdited,
    this.status = ProjectStatus.editing,
    this.clipsCount = 0,
    this.clips = const [],
    this.selectedClipIds = const [],
    this.exportedVideoPath,
  });

  factory Project.create({required String name, String? videoPath}) {
    return Project(
      id: const Uuid().v4(),
      name: name,
      videoPath: videoPath,
      createdAt: DateTime.now(),
      status: ProjectStatus.editing,
    );
  }

  Project copyWith({
    String? name,
    String? videoPath,
    Duration? duration,
    DateTime? lastEdited,
    ProjectStatus? status,
    int? clipsCount,
    List<Map<String, dynamic>>? clips,
    List<String>? selectedClipIds,
    String? exportedVideoPath,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      videoPath: videoPath ?? this.videoPath,
      duration: duration ?? this.duration,
      createdAt: createdAt,
      lastEdited: lastEdited ?? this.lastEdited,
      status: status ?? this.status,
      clipsCount: clipsCount ?? this.clipsCount,
      clips: clips ?? this.clips,
      selectedClipIds: selectedClipIds ?? this.selectedClipIds,
      exportedVideoPath: exportedVideoPath ?? this.exportedVideoPath,
    );
  }

  // ✅ Typed access to stored clips
  List<ViralClip> get viralClips =>
      clips.map((m) => ViralClip.fromMap(m)).toList();

  List<ViralClip> get selectedViralClips =>
      viralClips.where((c) => selectedClipIds.contains(c.id)).toList();

  bool isClipSelected(String clipId) => selectedClipIds.contains(clipId);

  double get averageConfidence {
    final vc = viralClips;
    if (vc.isEmpty) return 0.0;
    return vc.map((c) => c.confidence).reduce((a, b) => a + b) / vc.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'videoPath': videoPath,
      'durationSeconds': duration.inSeconds,
      'createdAt': createdAt.toIso8601String(),
      'lastEdited': lastEdited?.toIso8601String(),
      'status': status.name,
      'clipsCount': clipsCount,
      'clips': clips,
      'selectedClipIds': selectedClipIds,
      'exportedVideoPath': exportedVideoPath,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      videoPath: map['videoPath'] as String?,
      duration: Duration(seconds: map['durationSeconds'] as int? ?? 0),
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastEdited: map['lastEdited'] != null
          ? DateTime.parse(map['lastEdited'] as String)
          : null,
      status: ProjectStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String? ?? 'editing'),
        orElse: () => ProjectStatus.editing,
      ),
      clipsCount: map['clipsCount'] as int? ?? 0,
      clips: (map['clips'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      selectedClipIds: (map['selectedClipIds'] as List? ?? []).cast<String>(),
      exportedVideoPath: map['exportedVideoPath'] as String?,
    );
  }

  String get formattedDuration {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

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
        videoPath,
        duration,
        createdAt,
        lastEdited,
        status,
        clipsCount,
        clips,
        selectedClipIds,
        exportedVideoPath,
      ];
}

// 📚 What we're learning:
// - Entity = pure business object. Doesn't care HOW it's stored.
// - fromMap/toMap = manual serialization (no code generation!)
// - Equatable = easy value comparison for state management

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum ProjectStatus { editing, analyzing, ready, exporting }

class Project extends Equatable {
  final String id;
  final String name;
  final String? videoPath; // Path to source video on device
  final Duration duration; // Total video length
  final DateTime createdAt;
  final DateTime? lastEdited;
  final ProjectStatus status;
  final int clipsCount; // Number of AI-generated clips

  const Project({
    required this.id,
    required this.name,
    this.videoPath,
    this.duration = Duration.zero,
    required this.createdAt,
    this.lastEdited,
    this.status = ProjectStatus.editing,
    this.clipsCount = 0,
  });

  // Convenience: create a NEW project with auto-generated ID
  factory Project.create({required String name, String? videoPath}) {
    return Project(
      id: const Uuid().v4(), // Auto-generate unique ID
      name: name,
      videoPath: videoPath,
      createdAt: DateTime.now(),
      status: ProjectStatus.editing,
    );
  }

  // ──────────────────────────────────────────────
  // Manual serialization (for Hive storage)
  // ──────────────────────────────────────────────
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
    );
  }

  // Helper: format duration as "3:24" or "12:05"
  String get formattedDuration {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  // Helper: format date as "2h ago" or "Yesterday"
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
      ];
}

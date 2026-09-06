import 'package:hive/hive.dart';
import '../../domain/entities/project.dart';

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final videoPathRaw = reader.readString();
    final duration = Duration(seconds: reader.readInt());
    final createdAt = DateTime.parse(reader.readString());
    final lastEditedRaw = reader.readString();
    final status = ProjectStatus.values[reader.readInt()];
    final clipsCount = reader.readInt();
    final clipsRaw = reader.read();
    final selectedClipIds = reader.readStringList(); // ✅ new
    final exportedVideoPathRaw = reader.readString(); // ✅ new

    return Project(
      id: id,
      name: name,
      videoPath: videoPathRaw.isEmpty ? null : videoPathRaw,
      duration: duration,
      createdAt: createdAt,
      lastEdited: lastEditedRaw.isEmpty ? null : DateTime.parse(lastEditedRaw),
      status: status,
      clipsCount: clipsCount,
      clips: clipsRaw is List
          ? clipsRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
          : const [],
      selectedClipIds: selectedClipIds,
      exportedVideoPath:
          exportedVideoPathRaw.isEmpty ? null : exportedVideoPathRaw,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.videoPath ?? '');
    writer.writeInt(obj.duration.inSeconds);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.lastEdited?.toIso8601String() ?? '');
    writer.writeInt(obj.status.index);
    writer.writeInt(obj.clipsCount);
    writer.write(obj.clips);
    writer.writeStringList(obj.selectedClipIds); // ✅ new
    writer.writeString(obj.exportedVideoPath ?? ''); // ✅ new
  }
}

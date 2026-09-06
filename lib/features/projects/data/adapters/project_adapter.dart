import 'package:hive/hive.dart';
import '../../domain/entities/project.dart';

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    return Project(
      id: reader.readString(),
      name: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      videoPath: reader.read() as String?,
      duration: Duration(milliseconds: reader.readInt()),
      status: ProjectStatus.values[reader.readByte()],
      lastEdited: reader.readBool()
          ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
          : null,
      clipsCount: reader.readInt(),
      // ✅ NEW: Read clipsData list
      clipsData: (reader.readList() as List).cast<Map>(),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.videoPath);
    writer.writeInt(obj.duration.inMilliseconds);
    writer.writeByte(obj.status.index);
    writer.writeBool(obj.lastEdited != null);
    if (obj.lastEdited != null) {
      writer.writeInt(obj.lastEdited!.millisecondsSinceEpoch);
    }
    writer.writeInt(obj.clipsCount);
    // ✅ NEW: Write clipsData list
    writer.writeList(obj.clipsData);
  }
}

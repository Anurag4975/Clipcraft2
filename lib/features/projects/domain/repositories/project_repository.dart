import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<Project>>> getAllProjects();
  Future<Either<Failure, Project>> getProjectById(String id);
  Future<Either<Failure, Project>> saveProject(Project project);
  Future<Either<Failure, Unit>> deleteProject(String id);
  Future<Either<Failure, Unit>> updateProject(
      Project project); // ✅ ADD THIS LINE
}

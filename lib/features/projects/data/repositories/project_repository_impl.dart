import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final Box<Project> _box;

  ProjectRepositoryImpl(this._box);

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    try {
      final projects = _box.values.toList();
      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(projects);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    try {
      final project = _box.get(id);
      if (project == null) {
        return const Left(CacheFailure('Project not found'));
      }
      return Right(project);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Project>> saveProject(Project project) async {
    try {
      await _box.put(project.id, project);
      return Right(project);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(String id) async {
    try {
      await _box.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    try {
      await _box.put(project.id, project);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

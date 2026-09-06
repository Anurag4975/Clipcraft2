import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class UpdateProject implements UseCase<Unit, Project> {
  final ProjectRepository _repository;

  UpdateProject(this._repository);

  @override
  Future<Either<Failure, Unit>> call(Project project) async {
    return await _repository.updateProject(project);
  }
}

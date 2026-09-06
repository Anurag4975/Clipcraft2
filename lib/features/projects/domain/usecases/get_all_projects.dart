import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetAllProjects implements UseCase<List<Project>, NoParams> {
  final ProjectRepository _repository;

  GetAllProjects(this._repository);

  @override
  Future<Either<Failure, List<Project>>> call(NoParams params) async {
    return await _repository.getAllProjects();
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class SaveProjectParams extends Equatable {
  final Project project;
  const SaveProjectParams(this.project);

  @override
  List<Object?> get props => [project];
}

class SaveProject implements UseCase<Project, SaveProjectParams> {
  final ProjectRepository _repository;

  SaveProject(this._repository);

  @override
  Future<Either<Failure, Project>> call(SaveProjectParams params) async {
    return await _repository.saveProject(params.project);
  }
}

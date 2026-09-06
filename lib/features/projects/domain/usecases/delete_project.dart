import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/project_repository.dart';

class DeleteProjectParams extends Equatable {
  final String id;
  const DeleteProjectParams(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteProject implements UseCase<void, DeleteProjectParams> {
  final ProjectRepository _repository;

  DeleteProject(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteProjectParams params) async {
    return await _repository.deleteProject(params.id);
  }
}

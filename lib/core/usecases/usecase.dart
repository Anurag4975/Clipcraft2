import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Base class for all use cases
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters - ✅ Add const constructor
class NoParams extends Equatable {
  const NoParams(); // ✅ THIS MUST HAVE 'const'

  @override
  List<Object?> get props => [];
}

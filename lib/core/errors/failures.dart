import 'package:equatable/equatable.dart';

/// Base class for ALL errors in our app.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// ──────────────────────────────────────────────
// Specific error types
// ──────────────────────────────────────────────

/// When the server returns an error (404, 500, etc.)
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(String message, {this.statusCode}) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

/// When there's no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

/// When reading/writing local storage fails
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// When a purchase fails
class PurchaseFailure extends Failure {
  const PurchaseFailure(String message) : super(message);
}

/// When user hits their free daily limit
class DailyLimitExceededFailure extends Failure {
  final String featureName;
  const DailyLimitExceededFailure(this.featureName)
      : super('Daily limit exceeded for $featureName');

  @override
  List<Object?> get props => [message, featureName];
}

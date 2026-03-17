/// Base failure class for the entire app
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => '$runtimeType(message: $message)';
}

/// Internet / connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Backend / server-side failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(
    super.message, {
    this.statusCode,
  });
}

/// Authentication / authorization failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Input validation / form errors
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Cache / local storage issues
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Anything unexpected
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}


bool checkSuccess(Map<String, dynamic> map) {
  final b = map["success"] is bool
    ? map["success"]
    : bool.tryParse(map["success"]?.toString() ?? '') ?? false;
  
  if(!b){
    throw Exception(map["message"]);
  }
  return b;
}
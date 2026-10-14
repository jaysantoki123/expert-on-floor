abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String code;

  const AppException(this.message, {this.statusCode, required this.code});

  @override
  String toString() => 'AppException: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode})
      : super(code: 'NETWORK_ERROR');
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.statusCode})
      : super(code: 'AUTH_ERROR');
}

class AuthorizationException extends AppException {
  const AuthorizationException(super.message, {super.statusCode})
      : super(code: 'FORBIDDEN');
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException(super.message, {this.errors, super.statusCode})
      : super(code: 'VALIDATION_ERROR');
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode})
      : super(code: 'SERVER_ERROR');
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode})
      : super(code: 'NOT_FOUND');
}

class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.statusCode})
      : super(code: 'TIMEOUT');
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.statusCode})
      : super(code: 'UNKNOWN_ERROR');
}
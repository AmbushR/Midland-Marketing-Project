class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class AttendanceException extends AppException {
  const AttendanceException(super.message);
}

class UserException extends AppException {
  const UserException(super.message);
}

class CommentException extends AppException {
  const CommentException(super.message);
}

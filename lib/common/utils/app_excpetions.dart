
class AppException {
  final _message, _prefix;

  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return '$_prefix $_message';
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, 'Error during communication');
}

class BadRequestException extends AppException {
  BadRequestException([String? message]) : super(message, 'invalid request');
}

class UnauthorizedException extends AppException {
   UnauthorizedException([String? message])
      : super(message, 'UnauthorizedException request');

}
class ForbiddenException extends AppException {
  ForbiddenException([String? message])
      : super(message, 'Forbidden request');
}
class MethodNotAllowedException extends AppException {
  MethodNotAllowedException([String? message])
      : super(message, 'Method not allowed');
}
class InternalServerErrorException extends AppException {
  InternalServerErrorException([String? message])
      : super(message, 'Internal server error');
}
class NotFoundException extends AppException {
  NotFoundException([String? message])
      : super(message, 'Resource not found');
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message])
      : super(message, 'Invalid input');
}

class UnknownException extends AppException {
  UnknownException([String? message])
      : super(message, 'Unknown error');
}

class NetworkExceptions extends AppException {
  NetworkExceptions([String? message])
      : super(message, 'Network error');
}
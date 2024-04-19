import 'package:flutter/foundation.dart';

@immutable
abstract class BaseException<Type> implements Exception {
  const BaseException({required this.exceptionType, required this.message});
  final String message;
  final Type exceptionType;

  @override
  String toString() =>
      '$runtimeType :\nmessage => $message \ntype => $exceptionType';

  @override
  bool operator ==(Object other) {
    return other is BaseException<Type> &&
        other.message == message &&
        other.exceptionType == exceptionType;
  }

  @override
  int get hashCode => message.hashCode + exceptionType.hashCode;
}

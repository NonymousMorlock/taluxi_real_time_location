import 'package:real_time_location/src/exceptions/base_exception.dart';

class RealTimeLocationException
    extends BaseException<RealTimeLocationExceptionType> {
  const RealTimeLocationException({
    required super.message,
    required super.exceptionType,
  });

  const RealTimeLocationException.realTimeLocationUninitialized()
      : super(
          message:
              'Real time location service is not initialized before using it',
          exceptionType:
              RealTimeLocationExceptionType.realTimeLocationUninitialized,
        );

  const RealTimeLocationException.closestLocationNotFound()
      : super(
          message: 'Closest location not found',
          exceptionType: RealTimeLocationExceptionType.closestLocationNotFound,
        );

  const RealTimeLocationException.unknown()
      : super(
          message: 'Unknown exception reason',
          exceptionType: RealTimeLocationExceptionType.unknown,
        );

  const RealTimeLocationException.initializationFailed()
      : super(
          message: 'Initialization Failed',
          exceptionType: RealTimeLocationExceptionType.initializationFailed,
        );
// @override
// String toString() => 'RealTimeLocationException :\n' + message;
}

enum RealTimeLocationExceptionType {
  // locationPermissionDenied,
  realTimeLocationUninitialized,
  unknown,
  closestLocationNotFound,
  initializationFailed,
}

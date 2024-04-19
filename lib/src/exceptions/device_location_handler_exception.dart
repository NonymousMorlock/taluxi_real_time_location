import 'package:real_time_location/src/exceptions/base_exception.dart';

class DeviceLocationHandlerException
    extends BaseException<DeviceLocationHandlerExceptionType> {
  const DeviceLocationHandlerException({
    required super.message,
    required super.exceptionType,
  });

  const DeviceLocationHandlerException.permissionDenied()
      : super(
          message: 'Location access permission denied',
          exceptionType: DeviceLocationHandlerExceptionType.permissionDenied,
        );

  const DeviceLocationHandlerException.permissionPermanentlyDenied()
      : super(
          message: 'Location access permission is permanently denied',
          exceptionType:
              DeviceLocationHandlerExceptionType.permissionPermanentlyDenied,
        );

  const DeviceLocationHandlerException.insufficientPermission()
      : super(
          message: 'The granted permission is insufficient for the '
              'requested service.',
          exceptionType:
              DeviceLocationHandlerExceptionType.insufficientPermission,
        );

  const DeviceLocationHandlerException.locationServiceDisabled()
      : super(
          message: 'The location service is desabled',
          exceptionType:
              DeviceLocationHandlerExceptionType.locationServiceDisabled,
        );

  const DeviceLocationHandlerException.locationServiceUninitialized()
      : super(
          message: 'The location service is not initialized you '
              'must initialize it before using it.',
          exceptionType:
              DeviceLocationHandlerExceptionType.locationServiceUninitialized,
        );
}

enum DeviceLocationHandlerExceptionType {
  permissionDenied,
  permissionPermanentlyDenied,
  insufficientPermission,
  locationServiceDisabled,
  locationServiceUninitialized
}

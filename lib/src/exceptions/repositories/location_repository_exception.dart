import 'package:real_time_location/src/exceptions/base_exception.dart';

class LocationRepositoryException
    extends BaseException<LocationRepositoryExceptionType> {
  const LocationRepositoryException.notFound()
      : super(
          exceptionType: LocationRepositoryExceptionType.notFound,
          message: 'Location not found',
        );
  const LocationRepositoryException.serverError()
      : super(
          exceptionType: LocationRepositoryExceptionType.serverError,
          message: 'Server internal error',
        );

  const LocationRepositoryException.unknown()
      : super(
          exceptionType: LocationRepositoryExceptionType.unknown,
          message: 'Unknown exception reason',
        );

  const LocationRepositoryException.requestTimeout()
      : super(
          exceptionType: LocationRepositoryExceptionType.requestTimeout,
          message: 'Request timeout',
        );

  // LocationRepositoryException.failedToPutLocation()
  //     : super(
  //         exceptionType: LocationRepositoryExceptionType.failedToPutLocation,
  //         message:
  //             "Failed to put location (unknown reason, probably server error)",
  //       );
}

enum LocationRepositoryExceptionType {
  notFound,
  serverError,
  unknown,
  requestTimeout,
  // failedToPutLocation,
}

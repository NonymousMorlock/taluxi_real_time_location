import 'package:real_time_location/src/exceptions/base_exception.dart';

class LocationStreamerException
    extends BaseException<LocationStreamerExceptionType> {
  const LocationStreamerException({
    required super.message,
    required super.exceptionType,
  });

  const LocationStreamerException.dataAccessFailed()
      : super(
          exceptionType: LocationStreamerExceptionType.dataAccessFailed,
          message: 'Failed to retrieve location data from the database',
        );
}

enum LocationStreamerExceptionType { dataAccessFailed }

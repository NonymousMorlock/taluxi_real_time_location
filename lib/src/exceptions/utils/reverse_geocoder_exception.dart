import 'package:real_time_location/src/exceptions/base_exception.dart';

class ReverseGeocoderException
    extends BaseException<ReverseGeocoderExceptionType> {
  const ReverseGeocoderException.noResultFound()
      : super(
          exceptionType: ReverseGeocoderExceptionType.noResultFound,
          message: 'No Result Found',
        );
}

enum ReverseGeocoderExceptionType { noResultFound }

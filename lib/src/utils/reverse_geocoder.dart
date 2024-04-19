import 'package:geocoding/geocoding.dart';
import 'package:real_time_location/real_time_location.dart';

class ReverseGeocoder {
  Future<String> getCityFromCoordinates(Coordinates coordinates) async {
    try {
      final placeMarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      return placeMarks.first.subAdministrativeArea ?? '';
    } on NoResultFoundException {
      throw const ReverseGeocoderException.noResultFound();
    }
  }
}

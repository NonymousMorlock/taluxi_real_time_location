import 'package:dio/dio.dart';

import 'package:real_time_location/real_time_location.dart';

// TODO(Error-handling): handle errors
class LocationRepository {
  LocationRepository() {
    // _httpClient.options.baseUrl = 'https://taluxi-360b0.uc.r.appspot-review'
    //     '.com';
    _httpClient.options.baseUrl = 'http://localhost:3000';
    _httpClient.options.responseType = ResponseType.json;
  }
  final _httpClient = Dio();

  Future<void> putLocation({
    required String userId,
    required String city,
    required Coordinates coordinates,
  }) async {
    try {
      final result = await _httpClient.post(
        '/add',
        data: {
          'id': userId,
          'city': city,
          'coord': {'lat': coordinates.latitude, 'lon': coordinates.longitude},
        },
      );
    } on DioException catch (e) {
      throw _handleRequestErrors(e);
    }
  }

  // ignore: missing_return
  Future<Map<String, dynamic>> getClosestLocation({
    required String city,
    required Coordinates coordinates,
    double maxDistanceInKm = 2,
    int locationCount = 4,
  }) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/findClosest',
        data: {
          'city': city,
          'coord': {'lat': coordinates.latitude, 'lon': coordinates.longitude},
          'maxDistance': maxDistanceInKm,
          'count': locationCount,
        },
      );
      return response.data ?? {};
    } on DioException catch (e) {
      throw _handleRequestErrors(e);
    }
  }

  Future<void> deleteLocation({
    required String userId,
    required String city,
  }) async {
    try {
      await _httpClient.delete('/delete', data: {'city': city, 'id': userId});
    } on DioException catch (e) {
      throw _handleRequestErrors(e);
    }
  }

  LocationRepositoryException _handleRequestErrors(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const LocationRepositoryException.requestTimeout();
    }
    if (e.response != null) {
      if (e.response!.statusCode == 404) {
        return const LocationRepositoryException.notFound();
      }
      return const LocationRepositoryException.serverError();
    }
    return const LocationRepositoryException.unknown();
  }
}

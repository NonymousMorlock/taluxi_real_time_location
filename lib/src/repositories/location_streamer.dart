import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:real_time_location/src/exceptions/repositories/location_streamer_exception.dart';

class LocationStreamer {
  LocationStreamer({DatabaseReference? databaseReference})
      : _realTimeDatabase =
            databaseReference ?? FirebaseDatabase.instance.ref();
  @visibleForTesting
  static const onlineNode = 'online';
  final DatabaseReference _realTimeDatabase;

  Future<void> removeOnDisconnect({
    required String city,
    required String userId,
  }) async {
    await _realTimeDatabase
        .child('$onlineNode/$city/$userId')
        .onDisconnect()
        .remove();
  }

  Future<Map<String, double>?> getLocation({
    required String city,
    required String userUid,
  }) async {
    try {
      final coordinates =
          await _realTimeDatabase.child('$onlineNode/$city/$userUid').once();
      if (coordinates.snapshot.value == null) return null;
      return _coordinatesStringToMap(coordinates.snapshot.value! as String);
    } on FirebaseException {
      throw const LocationStreamerException.dataAccessFailed();
    }
  }

  Map<String, double> _coordinatesStringToMap(String coordinates) {
    final coordinatesList = coordinates.split('-');
    // return {
    //   'latitude': double.tryParse(coordinatesList.first) ?? 0.0
    //   'longitude': double.tryParse(coordinatesList.last),
    // };
    if (coordinatesList case [final String latitude, final String longitude]) {
      final finalLatitude = double.tryParse(latitude);
      final finalLongitude = double.tryParse(longitude);
      if (finalLongitude == null || finalLatitude == null) {
        throw const LocationStreamerException.dataAccessFailed();
      }
      return {
        'latitude': finalLatitude,
        'longitude': finalLongitude,
      };
    }
    throw const LocationStreamerException.dataAccessFailed();
  }

  Stream<Map<String, double>> getLocationStream({
    required String city,
    required String userUid,
  }) async* {
    try {
      final locationStream =
          _realTimeDatabase.child('$onlineNode/$city/$userUid').onValue;
      await for (final event in locationStream) {
        yield _coordinatesStringToMap(event.snapshot.value! as String);
      }
    } on FirebaseException {
      throw const LocationStreamerException.dataAccessFailed();
    }
  }

  Future<void> updateLocation({
    required String city,
    required String userUid,
    required Map<String, double> gpsCoordinates,
  }) async {
    try {
      await _realTimeDatabase
          .child('$onlineNode/$city/$userUid')
          .set(_coordinatesMapToString(gpsCoordinates));
    } on FirebaseException {
      throw const LocationStreamerException.dataAccessFailed();
    }
  }

  String _coordinatesMapToString(Map<String, double> coordinates) {
    return '${coordinates["latitude"]}-${coordinates["longitude"]}';
  }
}

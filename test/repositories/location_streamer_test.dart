import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_location/src/repositories/location_streamer.dart';

void main() {
  late DatabaseReference databaseReference;
  late LocationStreamer locationStreamer;
  const userUid = 'testUid';
  const otherUserUid = 'testNewUid';

  setUp(() {
    databaseReference = MockFirebaseDatabase.instance.reference();
    locationStreamer = LocationStreamer(databaseReference: databaseReference);
  });

  group('Taxi driver infos :', () {
    // Driver infos such as online, current location...
    const coordinates = {'latitude': 14.463742, 'longitude': 11.631249};
    const otherCoordinates = {'latitude': 16.403942, 'longitude': 10.038241};
    const city = 'city';
    MockFirebaseDatabase.instance
        .reference()
        .child(LocationStreamer.onlineNode)
        .child(city)
        .set({
      userUid: '${coordinates['latitude']}-${coordinates['longitude']}',
      otherUserUid:
          '${otherCoordinates['latitude']}-${otherCoordinates['longitude']}',
    });

    test(
        'Should return the coordinates of user which uid is passed in parameter',
        () async {
      final coordinates0 =
          await locationStreamer.getLocation(userUid: userUid, city: city);
      expect(coordinates0, equals(coordinates));
      final othercoordinates =
          await locationStreamer.getLocation(userUid: otherUserUid, city: city);
      expect(othercoordinates, equals(otherCoordinates));
    });
    test(
        'Should returns null when nonexistent user uid is passed in parameter.',
        () async {
      final othercoordinates =
          await locationStreamer.getLocation(userUid: 'fakeUid', city: city);
      expect(othercoordinates, isNull);
    });

    test(
        'Should return a stream of coordinates of user whose uid is passed in parameter',
        () async {
      final coordinatesStream =
          locationStreamer.getLocationStream(userUid: userUid, city: city);
      expect(coordinatesStream, isA<Stream<Map<String, double>>>());
      expect(await coordinatesStream.first, equals(coordinates));
    });
    // TODO: test write operations on taxi drivers information
    test('Should update the driver location', () async {
      var coordinates0 =
          await locationStreamer.getLocation(userUid: userUid, city: city);
      expect(coordinates0, equals(coordinates));
      await locationStreamer.updateLocation(
        city: city,
        gpsCoordinates: otherCoordinates,
        userUid: userUid,
      );
      coordinates0 =
          await locationStreamer.getLocation(userUid: userUid, city: city);
      expect(coordinates0, equals(otherCoordinates));
    });
  });
}

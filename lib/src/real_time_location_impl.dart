import 'dart:async';

import 'package:real_time_location/real_time_location.dart';
import 'package:real_time_location/src/device_location_handler_impl.dart';
import 'package:real_time_location/src/repositories/location_repository.dart';
import 'package:real_time_location/src/repositories/location_streamer.dart';
import 'package:real_time_location/src/utils/reverse_geocoder.dart';

//TODO handle error (convert all exception message to user friendly)
//TODO handle LocationRepository errors

class RealTimeLocationImpl implements RealTimeLocation {
  factory RealTimeLocationImpl() => _singleton;

  RealTimeLocationImpl._internal()
      : _locationStreamer = LocationStreamer(),
        _deviceLocationHandler = DeviceLocationHandlerImp(),
        _locationRepository = LocationRepository();

  RealTimeLocationImpl.forTest({
    required LocationStreamer locationStreamer,
    required DeviceLocationHandler deviceLocationHandler,
    required LocationRepository locationRepository,
  })  : _locationStreamer = locationStreamer,
        _deviceLocationHandler = deviceLocationHandler,
        _locationRepository = locationRepository;

  final LocationStreamer _locationStreamer;
  final DeviceLocationHandler _deviceLocationHandler;
  final LocationRepository _locationRepository;
  StreamSubscription? _locationStreamSubscription;
  String? _currentUserId;
  String? _city;
  double? _defaultDistanceFilter;
  var _isRideMode = false;
  var _initialized = false;

  static final _singleton = RealTimeLocationImpl._internal();

  @override
  bool get isRideMode => _isRideMode;

  @override
  bool get initialized => _initialized;

  @override
  Future<void> initialize({
    required String currentUserId,
    bool isDriverApp = true,
    ReverseGeocoder? reverseGeocoder,
  }) async {
    _currentUserId = currentUserId;
    if (_initialized) return;
    reverseGeocoder ??= ReverseGeocoder();
    await _deviceLocationHandler.initialize(requireBackground: isDriverApp);
    final currentCoordinates =
        await _deviceLocationHandler.getCurrentCoordinates();
    _city = await reverseGeocoder
        .getCityFromCoordinates(currentCoordinates)
        .catchError(
          (_) => throw const RealTimeLocationException.initializationFailed(),
        );
    if (isDriverApp) {
      await _locationStreamer.removeOnDisconnect(
        city: _city!,
        userId: _currentUserId!,
      );
    }
    _initialized = true;
  }

  @override
  Future<void> enableRideMode({double newDistanceFilter = 50}) async {
    //* In ride mode the driver must not be visible by the users which look for
    //* a closest driver, so we delete the location from the repository.
    //* The location will be automaticlly set by the location stream in the
    //* [startSharingLocation] function when the ride mode is disabled.
    if (_city == null || _currentUserId == null) {
      throw const RealTimeLocationException.initializationFailed();
    }
    await _locationRepository.deleteLocation(
      city: _city!,
      userId: _currentUserId!,
    );
    await _deviceLocationHandler.setDistanceFilter(newDistanceFilter);
    _isRideMode = true;
  }

  @override
  void disableRideMode() {
    if (_defaultDistanceFilter == null) {
      throw const RealTimeLocationException.initializationFailed();
    }
    _deviceLocationHandler.setDistanceFilter(_defaultDistanceFilter!);
    _isRideMode = false;
  }

  @override
  Stream<Coordinates> startLocationTracking(String idOfUserToTrack) {
    if (_city == null) {
      throw const RealTimeLocationException.initializationFailed();
    }
    return _locationStreamer
        .getLocationStream(city: _city!, userUid: idOfUserToTrack)
        .map(
      (coordinatesMap) {
        // if any of the coordinate maps doesn't have either latitude or
        // longitude, we don't want to add it to the stream.
        if (coordinatesMap
            case {
              'latitude': final double latitude,
              'longitude': final double longitude,
            }) {
          return Coordinates(
            latitude: latitude,
            longitude: longitude,
          );
        }
        throw const RealTimeLocationException.unknown();
      },
    );
  }

  @override
  void startSharingLocation({double distanceFilterInMeter = 1000}) {
    _defaultDistanceFilter = distanceFilterInMeter;
    _locationStreamSubscription = _deviceLocationHandler
        .getCoordinatesStream(distanceFilterInMeter: distanceFilterInMeter)
        .listen(_shareLocation);
  }

  void _shareLocation(Coordinates coordinates) {
    if (_city == null || _currentUserId == null) {
      throw const RealTimeLocationException.initializationFailed();
    }
    if (isRideMode) {
      _locationStreamer.updateLocation(
        city: _city!,
        userUid: _currentUserId!,
        gpsCoordinates: coordinates.toMap(),
      );
    } else {
      _locationRepository.putLocation(
        city: _city!,
        userId: _currentUserId!,
        coordinates: coordinates,
      );
    }
  }

  @override
  Future<void> stopLocationSharing() async {
    if (_city == null || _currentUserId == null) {
      throw const RealTimeLocationException.realTimeLocationUninitialized();
    }
    await _locationStreamSubscription?.cancel();
    await _locationRepository.deleteLocation(
      city: _city!,
      userId: _currentUserId!,
    );
  }

  @override
  Future<Map<String, dynamic>> getClosestDriversLocations({
    double maxDistanceInKm = 2,
    int locationCount = 4,
  }) async {
    try {
      if (_city == null) {
        throw const RealTimeLocationException.initializationFailed();
      }
      final coordinates = await _deviceLocationHandler.getCurrentCoordinates();
      return _locationRepository.getClosestLocation(
        city: _city!,
        coordinates: coordinates,
        maxDistanceInKm: maxDistanceInKm,
        locationCount: locationCount,
      );
    } on LocationRepositoryException catch (e) {
      if (e.exceptionType == LocationRepositoryExceptionType.notFound) {
        throw const RealTimeLocationException.closestLocationNotFound();
      } else {
        throw const RealTimeLocationException.unknown();
      }
    }
  }
}

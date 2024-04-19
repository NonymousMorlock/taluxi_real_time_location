import 'package:location/location.dart';
import 'package:real_time_location/real_time_location.dart';

/// The Device location manager.
///
/// This class provides some methods which will help you to use the device location.
class DeviceLocationHandlerImp implements DeviceLocationHandler {
  factory DeviceLocationHandlerImp() => _singleton;

  DeviceLocationHandlerImp._internal() : _location = Location();

  DeviceLocationHandlerImp.forTest({required Location location})
      : _location = location;
  Location _location;
  bool _locationServiceInitialized = false;

  static final _singleton = DeviceLocationHandlerImp._internal();

  // TODO: check if the device os version is android 11+ to decide weither to
  // todo: explan to the user how to always allow location permission or not.

  @override
  Future<void> initialize({bool requireBackground = false}) async {
    await _location.enableBackgroundMode(enable: requireBackground);
    await _requireLocationPermission();
    if (!(await _location.serviceEnabled()) &&
        !(await _location.requestService())) {
      throw const DeviceLocationHandlerException.locationServiceDisabled();
    }
    _locationServiceInitialized = true;
  }

  Future<void> _requireLocationPermission() async {
    final locationPermissionStatus = await _location.hasPermission();
    if (locationPermissionStatus != PermissionStatus.granted) {
      if (locationPermissionStatus == PermissionStatus.deniedForever) {
        throw const DeviceLocationHandlerException
            .permissionPermanentlyDenied();
      }
      await _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    switch (await _location.requestPermission()) {
      case PermissionStatus.denied:
        throw const DeviceLocationHandlerException.permissionDenied();
      case PermissionStatus.deniedForever:
        throw const DeviceLocationHandlerException
            .permissionPermanentlyDenied();
      default:
    }
  }

  @override
  Future<Coordinates> getCurrentCoordinates() async {
    if (!_locationServiceInitialized) {
      throw const DeviceLocationHandlerException.locationServiceUninitialized();
    }
    final locationData = await _location.getLocation();
    if (locationData
        case LocationData(
          :final double latitude,
          :final double longitude,
        )) {
      return Coordinates(
        latitude: latitude,
        longitude: longitude,
      );
    } else {
      throw const DeviceLocationHandlerException.locationServiceDisabled();
    }
  }

  @override
  Stream<Coordinates> getCoordinatesStream({
    double distanceFilterInMeter = 100,
  }) {
    if (!_locationServiceInitialized) {
      throw const DeviceLocationHandlerException.locationServiceUninitialized();
    }
    _location.changeSettings(distanceFilter: distanceFilterInMeter);
    return _location.onLocationChanged.map<Coordinates>(
      (locationData) {
        if (locationData
            case LocationData(
              :final double latitude,
              :final double longitude,
            )) {
          return Coordinates(
            latitude: latitude,
            longitude: longitude,
          );
        } else {
          throw const DeviceLocationHandlerException.locationServiceDisabled();
        }
      },
    );
  }

  @override
  Future<bool> setDistanceFilter(double distanceFilterInMeter) =>
      _location.changeSettings(distanceFilter: distanceFilterInMeter);
}

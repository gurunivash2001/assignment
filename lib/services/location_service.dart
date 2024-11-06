import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  Stream<Position>? positionStream;
  SharedPreferences? _prefs;

  LocationService() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> startLocationUpdates() async {
    positionStream = Geolocator.getPositionStream(
      locationSettings:  const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    positionStream?.listen((Position position) {
       _prefs?.setDouble('latitude', position.latitude);
      _prefs?.setDouble('longitude', position.longitude);
      _prefs?.setDouble('speed', position.speed);
     });
  }

  Future<void> stopLocationUpdates() async {
    positionStream = null;
  }

  Future<Map<String, double>> getLocationData() async {
    return {
      'latitude': _prefs?.getDouble('latitude') ?? 0.0,
      'longitude': _prefs?.getDouble('longitude') ?? 0.0,
      'speed': _prefs?.getDouble('speed') ?? 0.0,
    };
  }
}

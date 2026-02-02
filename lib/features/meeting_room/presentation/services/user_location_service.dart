import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class UserLocation {
  const UserLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  static const UserLocation defaultLocation = UserLocation(
    latitude: 25.033,
    longitude: 121.5654,
  );
}

class UserLocationService {
  Future<UserLocation> fetchAndLogLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return UserLocation.defaultLocation;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('Location permission denied: $permission');
      return UserLocation.defaultLocation;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      debugPrint(
        'User location: lat=${position.latitude}, lng=${position.longitude}',
      );
      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (error) {
      debugPrint('Failed to get location: $error');
      return UserLocation.defaultLocation;
    }
  }
}

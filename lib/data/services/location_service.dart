import 'package:geolocator/geolocator.dart';

import '../models/location_payload.dart';

class LocationService {
  Future<LocationPayload> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi belum aktif.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi belum diberikan.');
    }

    final position = await Geolocator.getCurrentPosition();
    return LocationPayload(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

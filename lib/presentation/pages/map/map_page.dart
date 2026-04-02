import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/models/attendance_model.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key, required this.attendance});

  final AttendanceModel attendance;

  @override
  Widget build(BuildContext context) {
    final latitude = attendance.latitude ?? 0;
    final longitude = attendance.longitude ?? 0;
    final position = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi Absensi')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: position,
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('attendance_location'),
            position: position,
            infoWindow: const InfoWindow(title: 'Lokasi absensi'),
          ),
        },
      ),
    );
  }
}

import 'package:absensi_raditya/page/login/login.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

// PERBAIKAN: Pastikan ejaan file controller benar (pakai double 't')
import 'package:absensi_raditya/api/controllers/attendance_controller.dart';
import 'package:absensi_raditya/api/preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userToken;
  bool isLoading = false;
  bool isAlreadyCheckIn = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    String? token = await AuthPreferences.getToken();
    setState(() => userToken = token);
  }

  Future<Position> _getGeoLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('GPS Anda mati, harap nyalakan.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void _processAbsence(bool isCheckIn) async {
    setState(() => isLoading = true);
    try {
      Position pos = await _getGeoLocation();

      // Mengambil alamat dari koordinat
      List<Placemark> marks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      Placemark place = marks[0];
      String address =
          "${place.street}, ${place.locality}, ${place.subAdministrativeArea}";

      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String time = DateFormat('HH:mm').format(DateTime.now());

      if (isCheckIn) {
        await AttendanceController.checkIn({
          "attendance_date": date,
          "check_in": time,
          "check_in_lat": pos.latitude,
          "check_in_lng": pos.longitude,
          "check_in_location": "${pos.latitude},${pos.longitude}",
          "check_in_address": address,
          "status": "masuk",
        });
        setState(() => isAlreadyCheckIn = true);
      } else {
        await AttendanceController.checkOut({
          "attendance_date": date,
          "check_out": time,
          "check_out_lat": pos.latitude,
          "check_out_lng": pos.longitude,
          "check_out_location": "${pos.latitude},${pos.longitude}",
          "check_out_address": address,
        });
        setState(() => isAlreadyCheckIn = false);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil ${isCheckIn ? 'Masuk' : 'Keluar'}!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Absensi Raditya"),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthPreferences.logout();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 30),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _absentButton(
                "CHECK IN",
                Colors.green,
                !isAlreadyCheckIn,
                () => _processAbsence(true),
              ),
              const SizedBox(height: 15),
              _absentButton(
                "CHECK OUT",
                Colors.red,
                isAlreadyCheckIn,
                () => _processAbsence(false),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Token Aktif:", style: TextStyle(color: Colors.white70)),
          SelectableText(
            userToken ?? "-",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const Divider(color: Colors.white24),
          Text(
            DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _absentButton(
    String label,
    Color color,
    bool enabled,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: enabled ? onTap : null,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

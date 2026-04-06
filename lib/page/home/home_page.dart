import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:intl/intl.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/api/controllers/atendance.dart';
import 'package:absensi_raditya/page/login/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userToken;
  bool isLoading = false;
  bool hasCheckedIn = false; // Status absensi
  bool hasCheckedOut = false; // Status absensi checkout

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    String? token = await AuthPreferences.getToken();
    setState(() {
      userToken = token;
    });
  }

  // Fungsi ambil lokasi Google
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled)
      return Future.error('GPS non-aktif. Harap nyalakan GPS.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return Future.error('Izin lokasi ditolak.');
    }
    return await Geolocator.getCurrentPosition();
  }

  // Fungsi Logika Absen
  void _handleAttendance(bool isCheckIn) async {
    setState(() => isLoading = true);
    try {
      Position position = await _determinePosition();
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(position.latitude, position.longitude);
      geocoding.Placemark place = placemarks.first;
      String address =
          "${place.name ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}";

      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String formattedTime = DateFormat('HH:mm').format(DateTime.now());

      if (isCheckIn) {
        await AttendanceController.processCheckIn({
          "attendance_date": formattedDate,
          "check_in": formattedTime,
          "check_in_lat": position.latitude,
          "check_in_lng": position.longitude,
          "check_in_address": address,
          "status": "masuk",
        });
        setState(() {
          hasCheckedIn = true;
          hasCheckedOut = false;
        });
      } else {
        await AttendanceController.processCheckOut({
          "attendance_date": formattedDate,
          "check_out": formattedTime,
          "check_out_lat": position.latitude.toString(),
          "check_out_lng": position.longitude.toString(),
          "check_out_location": "${position.latitude}, ${position.longitude}",
          "check_out_address": address,
        });
        setState(() {
          hasCheckedOut = true;
          hasCheckedIn = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${isCheckIn ? 'Check In' : 'Check Out'} Berhasil!"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Presensi App'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthPreferences.logout();
              if (mounted)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Info User & Token
            _buildUserCard(),
            const SizedBox(height: 25),

            const Text(
              "Menu Presensi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Card Tombol Absensi
            _buildAttendanceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Token Aktif:",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            userToken ?? "Memuat...",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(color: Colors.white24, height: 25),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selamat Datang,",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statusIndicator("Check In", hasCheckedIn),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey,
                ),
                _statusIndicator(
                  "Check Out",
                  hasCheckedOut,
                ), // Logika status check out
              ],
            ),
            const SizedBox(height: 30),
            if (isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton.icon(
                onPressed: hasCheckedIn ? null : () => _handleAttendance(true),
                icon: const Icon(Icons.login),
                label: const Text("CHECK IN"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: !hasCheckedIn
                    ? null
                    : () => _handleAttendance(false),
                icon: const Icon(Icons.logout),
                label: const Text("CHECK OUT"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              "*Pastikan GPS anda menyala sebelum absen",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusIndicator(String title, bool isDone) {
    return Column(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_off,
          color: isDone ? Colors.green : Colors.grey,
          size: 30,
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: isDone ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

import 'package:absensi_raditya/models/absen_inout.dart';
import 'package:absensi_raditya/page/home/profile.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:absensi_raditya/api/controllers/attendance_controller.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Untuk Google Map
  LatLng? _currentPosition;
  final double _defaultLat = -6.200000;
  final double _defaultLng = 106.816666;
  final double _mapZoom = 16;
  @override
  void initState() {
    super.initState();
    _initData();
    _fetchTodayAttendance();
    _setCurrentLocation();
    _fetchTodayAttendance();
  }

  Future<void> _setCurrentLocation() async {
    try {
      Position pos = await _getGeoLocation();
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      // Jika gagal, gunakan default Jakarta
      setState(() {
        _currentPosition = LatLng(_defaultLat, _defaultLng);
      });
    }
  }

  String? userToken;
  bool isLoading = false;
  bool isAlreadyCheckIn = false;
  bool isLoadingAttendance = true;
  bool isAlreadyAbsenToday = false;
  String? absenStatusMessage;
  // Simpan data absen hari ini jika perlu detail
  AttendanceData? todayAttendance;

  // Tema sesuai Logo
  final Color primaryBlue = const Color(0xFF005DA9);
  final Color secondaryYellow = const Color(0xFFFFCC00);

  Future<void> _fetchTodayAttendance() async {
    setState(() {
      isLoadingAttendance = true;
      absenStatusMessage = null;
    });
    try {
      final response = await AttendanceController.getTodayAttendance();
      todayAttendance = response.data;
      // Cek status absen hari ini
      if (todayAttendance != null && todayAttendance!.checkInTime != null) {
        isAlreadyCheckIn = true;
        // Jika sudah check out, tampilkan pesan sudah absen hari ini
        if (todayAttendance!.checkOutTime != null &&
            todayAttendance!.checkOutTime!.isNotEmpty) {
          isAlreadyAbsenToday = true;
          absenStatusMessage = "Anda sudah absen hari ini";
        } else {
          isAlreadyAbsenToday = false;
          absenStatusMessage = null;
        }
      } else {
        isAlreadyCheckIn = false;
        isAlreadyAbsenToday = false;
        absenStatusMessage = null;
      }
    } catch (e) {
      absenStatusMessage = "Gagal mengambil status absen: ${e.toString()}";
      isAlreadyCheckIn = false;
      isAlreadyAbsenToday = false;
    } finally {
      setState(() {
        isLoadingAttendance = false;
      });
    }
  }

  void _initData() async {
    String? token = await AuthPreferences.getToken();
    setState(() => userToken = token);
  }

  // --- FUNGSI YANG ERROR TADI (PASTIKAN ADA DI SINI) ---
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
      List<Placemark> marks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      Placemark place = marks[0];
      String address =
          "${place.street}, ${place.locality}, ${place.subAdministrativeArea}";

      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String time = DateFormat('HH:mm').format(DateTime.now());

      Map<String, dynamic> data = {
        "attendance_date": date,
        isCheckIn ? "check_in" : "check_out": time,
        "${isCheckIn ? 'check_in' : 'check_out'}_lat": pos.latitude,
        "${isCheckIn ? 'check_in' : 'check_out'}_lng": pos.longitude,
        "${isCheckIn ? 'check_in' : 'check_out'}_location":
            "${pos.latitude},${pos.longitude}",
        "${isCheckIn ? 'check_in' : 'check_out'}_address": address,
      };

      if (isCheckIn) {
        data["status"] = "masuk";
        await AttendanceController.checkIn(data);
      } else {
        await AttendanceController.checkOut(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil ${isCheckIn ? 'Check In' : 'Check Out'}!"),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh status absen hari ini setelah absen
      await _fetchTodayAttendance();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Absensi",
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: primaryBlue, size: 30),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            // Google Map
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _currentPosition == null
                    ? Center(
                        child: CircularProgressIndicator(color: primaryBlue),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: _mapZoom,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId("current_pos"),
                            position: _currentPosition!,
                            infoWindow: const InfoWindow(title: "Lokasi Anda"),
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                      ),
              ),
            ),
            const SizedBox(height: 24),
            if (isLoadingAttendance)
              CircularProgressIndicator(color: primaryBlue)
            else if (isAlreadyAbsenToday)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 28),
                    SizedBox(width: 12),
                    Text(
                      absenStatusMessage ?? "Anda sudah absen hari ini",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            else if (isLoading)
              CircularProgressIndicator(color: primaryBlue)
            else ...[
              _buildAbsenceButton(
                "CHECK IN",
                Colors.green,
                Icons.login,
                !isAlreadyCheckIn,
                () => _processAbsence(true),
              ),
              const SizedBox(height: 16),
              _buildAbsenceButton(
                "CHECK OUT",
                Colors.red,
                Icons.logout,
                isAlreadyCheckIn,
                () => _processAbsence(false),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, const Color(0xFF003D70)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            DateFormat('HH:mm').format(DateTime.now()),
            style: TextStyle(
              color: secondaryYellow,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user,
                color: Colors.greenAccent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isAlreadyCheckIn ? "Sudah Check In" : "Belum Absen",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenceButton(
    String label,
    Color color,
    IconData icon,
    bool enabled,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

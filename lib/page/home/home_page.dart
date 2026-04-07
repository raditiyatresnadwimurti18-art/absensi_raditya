import 'package:absensi_raditya/models/absen_inout.dart';
import 'package:absensi_raditya/models/usermodel.dart'; // Tambahkan import model User
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
  LatLng? _currentPosition;
  final double _defaultLat = -6.200000;
  final double _defaultLng = 106.816666;
  final double _mapZoom = 16;

  String? userToken;
  bool isLoading = false;
  bool isAlreadyCheckIn = false;
  bool isLoadingAttendance = true;
  bool isAlreadyAbsenToday = false;
  String? absenStatusMessage;
  AttendanceData? todayAttendance;

  final Color primaryBlue = const Color(0xFF005DA9);
  final Color secondaryYellow = const Color(0xFFFFCC00);

  @override
  void initState() {
    super.initState();
    _initData();
    _fetchTodayAttendance();
    _setCurrentLocation();
  }

  // --- LOGIKA DATA & LOKASI ---
  Future<void> _setCurrentLocation() async {
    try {
      Position pos = await _getGeoLocation();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(_defaultLat, _defaultLng);
        });
      }
    }
  }

  Future<void> _fetchTodayAttendance() async {
    setState(() {
      isLoadingAttendance = true;
      absenStatusMessage = null;
    });
    try {
      final response = await AttendanceController.getTodayAttendance();
      todayAttendance = response.data;
      if (todayAttendance != null && todayAttendance!.checkInTime != null) {
        isAlreadyCheckIn = true;
        if (todayAttendance!.checkOutTime != null &&
            todayAttendance!.checkOutTime!.isNotEmpty) {
          isAlreadyAbsenToday = true;
          absenStatusMessage = "Anda sudah absen hari ini";
        }
      } else {
        isAlreadyCheckIn = false;
        isAlreadyAbsenToday = false;
      }
    } catch (e) {
      absenStatusMessage = "Gagal mengambil status";
    } finally {
      if (mounted) setState(() => isLoadingAttendance = false);
    }
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
      if (permission == LocationPermission.denied)
        return Future.error('Izin lokasi ditolak.');
    }
    return await Geolocator.getCurrentPosition();
  }

  void _processAbsence(bool isCheckIn) async {
    final messenger = ScaffoldMessenger.of(context);
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

      Map<String, dynamic> data = {
        "attendance_date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        isCheckIn ? "check_in" : "check_out": DateFormat(
          'HH:mm',
        ).format(DateTime.now()),
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

      messenger.showSnackBar(
        SnackBar(
          content: Text("Berhasil ${isCheckIn ? 'Check In' : 'Check Out'}!"),
          backgroundColor: Colors.green,
        ),
      );
      await _fetchTodayAttendance();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
          // --- FOTO PROFIL DI APPBAR ---
          FutureBuilder<Map<String, dynamic>?>(
            future: AuthPreferences.getUserData(),
            builder: (context, snapshot) {
              String? photoUrl;
              if (snapshot.hasData && snapshot.data != null) {
                photoUrl = snapshot.data!['profile_photo'];
              }
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ).then((_) => setState(() {})),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Icon(Icons.person, color: primaryBlue, size: 20)
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildMapSection(),
            const SizedBox(height: 24),
            _buildAttendanceStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthPreferences.getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.hasData
            ? User.fromJson(snapshot.data!)
            : null;

        // Ambil data jam dari todayAttendance yang sudah di-fetch di initState
        String checkInTime = todayAttendance?.checkInTime ?? "--:--";
        String checkOutTime = todayAttendance?.checkOutTime ?? "--:--";

        return Container(
          width: double.infinity,
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
              // Row Profil (Tetap sama seperti sebelumnya)
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    backgroundImage:
                        (userData?.profilePhoto != null &&
                            userData!.profilePhoto!.isNotEmpty)
                        ? NetworkImage(userData.profilePhoto!)
                        : null,
                    child:
                        (userData?.profilePhoto == null ||
                            userData!.profilePhoto!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo,",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          userData?.name ?? "Pengguna",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(DateTime.now()),
                        style: TextStyle(
                          color: secondaryYellow,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM').format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 32),

              // --- BAGIAN RIWAYAT ABSEN JAM (PERUBAHAN DI SINI) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeInfo("Check In", checkInTime, Icons.login_rounded),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white24,
                  ), // Garis pembatas vertikal
                  _buildTimeInfo(
                    "Check Out",
                    checkOutTime,
                    Icons.logout_rounded,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper Widget untuk menampilkan jam agar rapi
  Widget _buildTimeInfo(String label, String time, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: secondaryYellow, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _currentPosition == null
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: _mapZoom,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("current_pos"),
                    position: _currentPosition!,
                  ),
                },
                myLocationEnabled: true,
                zoomControlsEnabled: false,
              ),
      ),
    );
  }

  Widget _buildAttendanceStatus() {
    if (isLoadingAttendance)
      return CircularProgressIndicator(color: primaryBlue);
    if (isAlreadyAbsenToday) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(
              absenStatusMessage ?? "Absensi Selesai",
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    if (isLoading) return CircularProgressIndicator(color: primaryBlue);
    return Column(
      children: [
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
      height: 55,
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

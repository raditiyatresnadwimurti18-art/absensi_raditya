import 'package:absensi_raditya/models/absen_inout.dart';
import 'package:absensi_raditya/models/profile_model.dart';
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
  bool isLoading = false;
  bool isLoadingAttendance = true;
  AttendanceData? todayAttendance;

  final Color primaryBlue = const Color(0xFF005DA9);
  final Color secondaryYellow = const Color(0xFFFFCC00);

  @override
  void initState() {
    super.initState();
    _fetchTodayAttendance();
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    try {
      Position pos = await _getGeoLocation();
      if (mounted)
        setState(() => _currentPosition = LatLng(pos.latitude, pos.longitude));
    } catch (e) {
      if (mounted)
        setState(() => _currentPosition = const LatLng(-6.2000, 106.8166));
    }
  }

  Future<void> _fetchTodayAttendance() async {
    if (!mounted) return;
    setState(() => isLoadingAttendance = true);
    try {
      final response = await AttendanceController.getTodayAttendance();
      setState(() => todayAttendance = response.data);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => isLoadingAttendance = false);
    }
  }

  Future<Position> _getGeoLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('GPS non-aktif.');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return Future.error('Izin lokasi ditolak.');
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
      String address = "${marks[0].street}, ${marks[0].locality}";

      Map<String, dynamic> data = {
        "attendance_date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        isCheckIn ? "check_in" : "check_out": DateFormat(
          'HH:mm',
        ).format(DateTime.now()),
        "${isCheckIn ? 'check_in' : 'check_out'}_location":
            "${pos.latitude},${pos.longitude}",
        "${isCheckIn ? 'check_in' : 'check_out'}_address": address,
      };

      if (isCheckIn) {
        await AttendanceController.checkIn(data);
      } else {
        await AttendanceController.checkOut(data);
      }

      _showSnackBar(
        "Berhasil ${isCheckIn ? 'Masuk' : 'Keluar'}!",
        Colors.green,
      );
      _fetchTodayAttendance();
    } catch (e) {
      _showSnackBar(e.toString().replaceAll("Exception: ", ""), Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _processIzin() async {
    final TextEditingController alasanController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Form Pengajuan Izin"),
        content: TextField(
          controller: alasanController,
          decoration: const InputDecoration(hintText: "Contoh: Sakit demam"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (alasanController.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => isLoading = true);
              try {
                await AttendanceController.postLeave(alasanController.text);
                _showSnackBar("Izin berhasil dikirim!", Colors.orange);
                _fetchTodayAttendance();
              } catch (e) {
                _showSnackBar(
                  e.toString().replaceAll("Exception: ", ""),
                  Colors.red,
                );
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            },
            child: const Text("Kirim"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Presensi Digital",
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
        actions: [_buildProfileAvatar()],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTodayAttendance,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 25),
              _buildMapSection(),
              const SizedBox(height: 25),
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthPreferences.getUserData(),
      builder: (context, snapshot) {
        String? photoUrl = snapshot.data?['profile_photo_url'];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ).then((_) => _fetchTodayAttendance()),
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
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
    );
  }

  Widget _buildHeaderCard() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthPreferences.getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.hasData
            ? Data.fromJson(snapshot.data!)
            : null;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [primaryBlue, const Color(0xFF003D70)],
            ),
            boxShadow: [
              BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Karyawan",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        userData?.name ?? "User",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildLiveClock(),
                ],
              ),
              const Divider(color: Colors.white24, height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeDetail(
                    "In",
                    todayAttendance?.checkInTime ?? "--:--",
                  ),
                  _buildTimeDetail(
                    "Out",
                    todayAttendance?.checkOutTime ?? "--:--",
                  ),
                  _buildTimeDetail(
                    "Status",
                    todayAttendance?.status ?? "Ready",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveClock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat('HH:mm').format(DateTime.now()),
          style: TextStyle(
            color: secondaryYellow,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          DateFormat('dd MMM yyyy').format(DateTime.now()),
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTimeDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 16,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("pos"),
                    position: _currentPosition!,
                  ),
                },
                myLocationEnabled: true,
                zoomControlsEnabled: false,
              ),
      ),
    );
  }

  Widget _buildActionSection() {
    if (isLoadingAttendance) return const CircularProgressIndicator();

    bool hasCheckIn = todayAttendance?.checkInTime != null;
    bool hasCheckOut = todayAttendance?.checkOutTime != null;
    bool isIzin = todayAttendance?.status?.toLowerCase() == "izin";

    if (hasCheckOut)
      return _buildInfoTile(
        "Presensi hari ini selesai",
        Colors.green,
        Icons.check_circle,
      );
    if (isIzin)
      return _buildInfoTile("Status: Izin", Colors.orange, Icons.event_note);

    return Column(
      children: [
        if (!hasCheckIn) ...[
          _buildButton(
            "CHECK IN",
            Colors.green,
            Icons.login,
            () => _processAbsence(true),
          ),
          const SizedBox(height: 12),
          _buildButton("IZIN / SAKIT", Colors.orange, Icons.mail, _processIzin),
        ] else ...[
          _buildButton(
            "CHECK OUT",
            Colors.red,
            Icons.logout,
            () => _processAbsence(false),
          ),
        ],
      ],
    );
  }

  Widget _buildButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback action,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : action,
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String text, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

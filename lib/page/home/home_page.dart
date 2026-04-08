import 'dart:ui';
import 'package:absensi_raditya/models/absen_inout.dart';
import 'package:absensi_raditya/page/home/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  LatLng? _currentPosition;
  bool isLoading = false;
  bool isLoadingAttendance = true;
  AttendanceData? todayAttendance;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // WARNA DISESUAIKAN DENGAN LOGO
  final Color primaryBlue = const Color(0xFF0074B7);
  final Color primaryYellow = const Color(0xFFFFD700);
  final Color lightBg = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _fetchTodayAttendance();
    _setCurrentLocation();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- LOGIKA BACKEND TETAP SAMA ---
  Future<void> _setCurrentLocation() async {
    try {
      Position pos = await _getGeoLocation();
      if (mounted) {
        setState(() => _currentPosition = LatLng(pos.latitude, pos.longitude));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentPosition = const LatLng(-6.2000, 106.8166));
      }
    }
  }

  Future<void> _fetchTodayAttendance() async {
    if (!mounted) return;
    setState(() => isLoadingAttendance = true);
    try {
      final response = await AttendanceController.getTodayAttendance();
      setState(() => todayAttendance = response.data);
    } catch (e) {
      debugPrint("Error Fetch: $e");
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
      String prefix = isCheckIn ? "check_in" : "check_out";

      Map<String, dynamic> data = {
        "attendance_date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        prefix: DateFormat('HH:mm').format(DateTime.now()),
        "${prefix}_lat": pos.latitude.toString(),
        "${prefix}_lng": pos.longitude.toString(),
        "${prefix}_address": address,
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
      _showSnackBar(
        e.toString().replaceAll("Exception: ", ""),
        Colors.redAccent,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _processIzin() async {
    final TextEditingController alasanController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Form Pengajuan Izin"),
        content: TextField(
          controller: alasanController,
          decoration: const InputDecoration(
            hintText: "Contoh: Sakit demam",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryYellow),
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
            child: const Text("Kirim", style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // --- UI SECTION DENGAN SENTUHAN LOGO ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: Stack(
        children: [
          _buildBackgroundMap(),
          _buildCircleDecorations(), // Tambahan dekorasi elemen lingkaran
          _buildGradientOverlay(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildMainContent(),
              ),
            ),
          ),
          _buildCustomAppBar(),
        ],
      ),
    );
  }

  // Elemen lingkaran dekoratif agar mirip logo
  Widget _buildCircleDecorations() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.25,
      right: -50,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primaryYellow.withOpacity(0.3), width: 40),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          bottom: 25,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildTimeHeader(), _buildProfileAvatar()],
        ),
      ),
    );
  }

  Widget _buildTimeHeader() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM').format(DateTime.now()),
              style: TextStyle(
                color: primaryYellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('HH:mm').format(DateTime.now()),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundMap() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: _currentPosition == null
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
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
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            lightBg.withOpacity(0.2),
            lightBg,
            lightBg,
          ],
          stops: const [0.0, 0.35, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _fetchTodayAttendance,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.38),
            _buildStatusGrid(),
            const SizedBox(height: 30),
            Row(
              children: [
                Container(width: 4, height: 20, color: primaryYellow),
                const SizedBox(width: 8),
                const Text(
                  "Presensi Hari Ini",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            "Masuk",
            todayAttendance?.checkInTime ?? "--:--",
            Icons.login_rounded,
            primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            "Pulang",
            todayAttendance?.checkOutTime ?? "--:--",
            Icons.logout_rounded,
            primaryYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: primaryBlue,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    if (isLoadingAttendance)
      return const Center(child: CircularProgressIndicator());

    bool hasCheckIn = todayAttendance?.checkInTime != null;
    bool hasCheckOut = todayAttendance?.checkOutTime != null;
    bool isIzin = todayAttendance?.status?.toLowerCase() == "izin";

    if (isIzin)
      return _buildStatusTile("Anda sedang Izin/Sakit", Colors.orange);
    if (hasCheckOut)
      return _buildStatusTile("Presensi hari ini selesai", Colors.green);

    return Column(
      children: [
        if (!hasCheckIn) ...[
          _buildMainActionButton(
            "CHECK IN MASUK",
            primaryBlue,
            Icons.fingerprint_rounded,
            () => _processAbsence(true),
          ),
          const SizedBox(height: 12),
          _buildSecondaryActionButton("Izin / Sakit", () => _processIzin()),
        ] else ...[
          _buildMainActionButton(
            "CHECK OUT PULANG",
            const Color(0xFFE53935),
            Icons.power_settings_new_rounded,
            () => _processAbsence(false),
          ),
        ],
      ],
    );
  }

  Widget _buildMainActionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback action,
  ) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : action,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, color: Colors.white, size: 30),
        label: Text(
          isLoading ? "MEMPROSES..." : text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton(String text, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: isLoading ? null : action,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primaryBlue.withOpacity(0.3), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTile(String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
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
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryYellow, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : null,
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? Icon(Icons.person, color: primaryBlue, size: 30)
                  : null,
            ),
          ),
        );
      },
    );
  }
}

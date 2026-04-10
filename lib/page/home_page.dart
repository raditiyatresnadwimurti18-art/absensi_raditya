import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:absensi_raditya/api/controllers/attendance_controller.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/models/absen_inout.dart';
import 'package:absensi_raditya/theme/app_theme.dart';
import 'package:absensi_raditya/widgets/home/home_appbar.dart';
import 'package:absensi_raditya/widgets/home/status_grid.dart';
import 'package:absensi_raditya/widgets/home/action_section.dart';

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

  // ─── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
    _fetchTodayAttendance();
    _setupAnimations();
  }

  void _setupAnimations() {
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

  // ─── Data & Lokasi ──────────────────────────────────────────────

  Future<void> _setCurrentLocation() async {
    try {
      final pos = await _getGeoLocation();
      if (mounted) {
        setState(() => _currentPosition = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _currentPosition = const LatLng(-6.2000, 106.8166));
      }
    }
  }

  Future<Position> _getGeoLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return Future.error('GPS non-aktif.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }
    return Geolocator.getCurrentPosition();
  }

  Future<void> _fetchTodayAttendance() async {
    if (!mounted) return;
    setState(() => isLoadingAttendance = true);

    try {
      final response = await AttendanceController.getTodayAttendance();
      AttendanceData? data = response.data;

      final historyResponse = await AttendanceController.getHistory();
      final todayStr = DateFormat('yyyy-MM-dd', 'id_ID').format(DateTime.now());

      try {
        final todayRecord = historyResponse.data?.firstWhere(
          (e) => e.attendanceDate == todayStr,
        );
        if (todayRecord != null && data != null) {
          data.id = todayRecord.id;
        }
      } catch (_) {
        debugPrint("Belum ada data history hari ini.");
      }

      setState(() => todayAttendance = data);
    } catch (e) {
      debugPrint("Error Fetch: $e");
      setState(() => todayAttendance = null);
    } finally {
      if (mounted) setState(() => isLoadingAttendance = false);
    }
  }

  // ─── Aksi Presensi ──────────────────────────────────────────────

  void _processAbsence(bool isCheckIn) async {
    setState(() => isLoading = true);
    try {
      final pos = await _getGeoLocation();
      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final address = "${marks[0].street}, ${marks[0].locality}";
      final prefix = isCheckIn ? "check_in" : "check_out";

      final data = {
        "attendance_date": DateFormat(
          'yyyy-MM-dd',
          'id_ID',
        ).format(DateTime.now()),
        prefix: DateFormat('HH:mm', 'id_ID').format(DateTime.now()),
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
        "Berhasil ${isCheckIn ? 'Check In' : 'Check Out'}!",
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

  void _processIzin() {
    final alasanCtrl = TextEditingController();
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: appColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Form Pengajuan Izin",
          style: TextStyle(color: appColors.text),
        ),
        content: TextField(
          controller: alasanCtrl,
          style: TextStyle(color: appColors.text),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
            ),
            onPressed: () async {
              if (alasanCtrl.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => isLoading = true);
              try {
                await AttendanceController.postLeave(alasanCtrl.text);
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

  void _processDeleteAbsence() async {
    final userData = await AuthPreferences.getUserData();
    final int? attendanceId = todayAttendance?.id;

    if (attendanceId == null) {
      _showSnackBar("ID Absensi tidak valid", Colors.orange);
      return;
    }

    final passwordCtrl = TextEditingController();
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: appColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Konfirmasi Keamanan",
          style: TextStyle(color: appColors.text, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Masukkan password akun Anda untuk menghapus data absensi hari ini.",
              style: TextStyle(color: appColors.subText, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              style: TextStyle(color: appColors.text),
              decoration: InputDecoration(
                hintText: "Password Anda",
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordCtrl.dispose();
              Navigator.pop(context);
            },
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final password = passwordCtrl.text.trim();
              if (password.isEmpty) {
                _showSnackBar("Password wajib diisi!", Colors.orange);
                return;
              }

              Navigator.pop(context);
              setState(() => isLoading = true);

              try {
                final result = await AttendanceController.deleteAttendance(
                  attendanceId,
                  userData?['name'] ?? "",
                  userData?['email'] ?? "",
                  password,
                );

                if (mounted) {
                  _showSnackBar(
                    result.message ?? "Berhasil dihapus",
                    Colors.blueGrey,
                  );
                  setState(() {
                    todayAttendance = null;
                    isLoadingAttendance = true;
                  });
                  await _fetchTodayAttendance();
                }
              } catch (e) {
                if (mounted) _showSnackBar(e.toString(), Colors.redAccent);
              } finally {
                passwordCtrl.dispose();
                if (mounted) setState(() => isLoading = false);
              }
            },
            child: const Text(
              "Hapus Sekarang",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helper ─────────────────────────────────────────────────────

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

  // ─── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.background,
      body: Stack(
        children: [
          _buildBackgroundMap(),
          _buildCircleDecoration(),
          _buildGradientOverlay(appColors.background),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildScrollContent(),
              ),
            ),
          ),
          const HomeAppBar(),
        ],
      ),
    );
  }

  Widget _buildBackgroundMap() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
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

  Widget _buildCircleDecoration() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.25,
      right: -50,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryYellow.withOpacity(0.3),
            width: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay(Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            bgColor.withOpacity(0.2),
            bgColor,
            bgColor,
          ],
          stops: const [0.0, 0.35, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildScrollContent() {
    return RefreshIndicator(
      onRefresh: _fetchTodayAttendance,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.38),
            StatusGrid(todayAttendance: todayAttendance),
            const SizedBox(height: 30),
            _buildSectionTitle("Presensi Hari Ini"),
            const SizedBox(height: 16),
            ActionSection(
              isLoading: isLoading,
              isLoadingAttendance: isLoadingAttendance,
              todayAttendance: todayAttendance,
              onCheckIn: () => _processAbsence(true),
              onCheckOut: () => _processAbsence(false),
              onIzin: _processIzin,
              onDelete: _processDeleteAbsence,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: AppColors.primaryYellow),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.appColors.text,
          ),
        ),
      ],
    );
  }
}

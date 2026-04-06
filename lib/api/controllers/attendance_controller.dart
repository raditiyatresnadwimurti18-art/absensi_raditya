import 'package:absensi_raditya/api/api_service.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/models/absen_inout.dart'; // Sesuaikan nama model kamu

class AttendanceController {
  // Ambil status absen hari ini
  static Future<AttendanceResponse> getTodayAttendance() async {
    String? token = await AuthPreferences.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    final response = await ApiService.getAttendanceToday(token);
    final result = attendanceResponseFromJson(response.body);

    if (response.statusCode == 200) {
      return result;
    } else {
      throw Exception(result.message ?? "Gagal mengambil data absen hari ini");
    }
  }

  // Pastikan ada kata 'static'
  static Future<AttendanceResponse> checkIn(Map<String, dynamic> body) async {
    String? token = await AuthPreferences.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    final response = await ApiService.postAttendance(
      "absen/check-in",
      token,
      body,
    );
    final result = attendanceResponseFromJson(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return result;
    } else {
      throw Exception(result.message ?? "Gagal Check-in");
    }
  }

  static Future<AttendanceResponse> checkOut(Map<String, dynamic> body) async {
    String? token = await AuthPreferences.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    final response = await ApiService.postAttendance(
      "absen/check-out",
      token,
      body,
    );
    final result = attendanceResponseFromJson(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return result;
    } else {
      throw Exception(result.message ?? "Gagal Check-out");
    }
  }
}

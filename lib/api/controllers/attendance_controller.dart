import 'package:absensi_raditya/api/api_service.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/models/absen_inout.dart';
import 'package:intl/intl.dart';

class AttendanceController {
  static Future<AttendanceResponse> getTodayAttendance() async {
    String? token = await AuthPreferences.getToken();
    if (token == null) throw Exception("Sesi berakhir.");

    final response = await ApiService.get("absen/today", token);
    final result = attendanceResponseFromJson(response.body);

    // FIX: Jika status 200, kembalikan data.
    // Jika tidak (misal 404 karena belum ada absen), jangan lempar exception dulu,
    // tapi kembalikan object result agar UI bisa membaca bahwa data masih null.
    if (response.statusCode == 200) {
      return result;
    } else {
      // Mengembalikan result meskipun isinya null/pesan "Belum ada data"
      return result;
    }
  }

  static Future<AttendanceResponse> checkIn(Map<String, dynamic> body) async {
    AttendanceResponse currentStatus = await getTodayAttendance();

    // Validasi Izin
    if (currentStatus.data?.status?.toLowerCase() == "izin") {
      throw Exception("Anda sudah izin hari ini.");
    }

    String? token = await AuthPreferences.getToken();
    final response = await ApiService.post("absen/check-in", token!, body);
    final result = attendanceResponseFromJson(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return result;
    } else {
      throw Exception(result.message ?? "Gagal Check-in.");
    }
  }

  static Future<AttendanceResponse> postLeave(String alasan) async {
    AttendanceResponse currentStatus = await getTodayAttendance();

    // Validasi: Jika data sudah ada dan sudah ada jam masuk
    if (currentStatus.data != null && currentStatus.data!.checkInTime != null) {
      throw Exception("Sudah absen masuk, tidak bisa izin.");
    }

    // Payload SESUAI PARAMETER yang kamu berikan
    Map<String, dynamic> body = {
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "alasan_izin": alasan,
    };

    String? token = await AuthPreferences.getToken();
    final response = await ApiService.post("absen/izin", token!, body);
    final result = attendanceResponseFromJson(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return result;
    } else {
      throw Exception(result.message ?? "Gagal kirim izin.");
    }
  }

  static Future<AttendanceResponse> checkOut(Map<String, dynamic> body) async {
    String? token = await AuthPreferences.getToken();
    final response = await ApiService.post("absen/check-out", token!, body);
    final result = attendanceResponseFromJson(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) return result;
    throw Exception(result.message ?? "Gagal Check-out.");
  }
}

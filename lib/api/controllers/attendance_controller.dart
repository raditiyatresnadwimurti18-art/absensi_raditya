import 'dart:convert';

import 'package:absensi_raditya/api/api_service.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/models/absen_inout.dart';
import 'package:absensi_raditya/models/riwayat_absen.dart';
import 'package:intl/intl.dart';

class AttendanceController {
  static Future<AttendanceResponse> getTodayAttendance() async {
    String? token = await AuthPreferences.getToken();
    if (token == null) throw Exception("Sesi berakhir.");

    final response = await ApiService.get("absen/today", token);
    final result = attendanceResponseFromJson(response.body);
    if (response.statusCode == 200) {
      return result;
    } else {
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
    final response = await ApiService.post("izin", token!, body);
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

  static Future<HistoryResponse> getHistory() async {
    try {
      // 1. Ambil token saja
      String? token = await AuthPreferences.getToken();

      if (token == null) {
        throw Exception("Sesi berakhir, silakan login kembali.");
      }

      // 2. Panggil API Service menggunakan method GET (karena hanya mengambil data)
      // Jika backend kamu mewajibkan POST meskipun tanpa body email/pass,
      // ganti ApiService.get menjadi ApiService.post(endpoint, token, {})
      final response = await ApiService.get("absen/history", token);

      if (response.statusCode == 200) {
        return historyResponseFromJson(response.body);
      } else {
        final errorResult = jsonDecode(response.body);
        throw Exception(errorResult['message'] ?? "Gagal mengambil riwayat");
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteAttendance(
    int id,
    String name,
    String email,
    String password,
  ) async {
    String? token = await AuthPreferences.getToken();
    if (token == null) throw Exception("Sesi berakhir.");

    // Body sesuai gambar Postman yang kamu berikan
    Map<String, dynamic> body = {
      "name": name,
      "email": email,
      "password": password,
    };

    // Endpoint: /api/absen/{id}
    final response = await ApiService.delete("absen/$id", token, body);

    final result = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(result['message'] ?? "Gagal menghapus data dari server.");
    }
  }
}

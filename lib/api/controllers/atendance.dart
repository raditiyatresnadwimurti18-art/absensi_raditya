import 'dart:convert';
import 'package:absensi_raditya/api/api_service.dart';
import 'package:absensi_raditya/api/preferences.dart';

class AttendanceController {
  /// Fungsi untuk menangani Check-In
  /// Menerima map data yang berisi:
  /// attendance_date, check_in, check_in_lat, check_in_lng, check_in_address, status
  static Future<void> processCheckIn(Map<String, dynamic> data) async {
    // 1. Ambil token yang tersimpan di SharedPreferences
    String? token = await AuthPreferences.getToken();

    if (token == null) {
      throw Exception("Sesi Anda habis. Silakan login kembali.");
    }

    // 2. Kirim data ke ApiService
    final response = await ApiService.checkIn(token: token, data: data);

    // 3. Validasi Response
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Berhasil
      return;
    } else {
      // Gagal (misal: sudah absen, atau data tidak lengkap)
      final errorBody = jsonDecode(response.body);
      String errorMessage = errorBody["message"] ?? "Gagal melakukan Check-in";

      // Jika ada detail error validasi dari backend
      if (errorBody["errors"] != null) {
        var validation = errorBody["errors"] as Map<String, dynamic>;
        errorMessage = validation.values.first[0].toString();
      }

      throw Exception(errorMessage);
    }
  }

  /// Fungsi untuk menangani Check-Out
  /// Menerima map data yang berisi:
  /// attendance_date, check_out, check_out_lat, check_out_lng, check_out_location, check_out_address
  static Future<void> processCheckOut(Map<String, dynamic> data) async {
    // 1. Ambil token
    String? token = await AuthPreferences.getToken();

    if (token == null) {
      throw Exception("Sesi Anda habis. Silakan login kembali.");
    }

    // 2. Kirim data ke ApiService
    final response = await ApiService.checkOut(token: token, data: data);

    // 3. Validasi Response
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Berhasil
      return;
    } else {
      final errorBody = jsonDecode(response.body);
      String errorMessage = errorBody["message"] ?? "Gagal melakukan Check-out";

      if (errorBody["errors"] != null) {
        var validation = errorBody["errors"] as Map<String, dynamic>;
        errorMessage = validation.values.first[0].toString();
      }

      throw Exception(errorMessage);
    }
  }
}

import 'dart:convert';
import 'package:absensi_raditya/api/api_service.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/models/usermodel.dart';

class AuthController {
  static Future<Welcome?> register({
    required String name,
    required String email,
    required String password,
    required String batchId,
    required String trainingId,
    required String jenisKelamin, // Nilai dari UI: "Laki-laki" atau "Perempuan"
  }) async {
    // --- MAPPING JENIS KELAMIN KE KETENTUAN BACKEND (L/P) ---
    String genderCode = "L"; // Default
    if (jenisKelamin == "Perempuan") {
      genderCode = "P";
    } else if (jenisKelamin == "Laki-laki") {
      genderCode = "L";
    } else {
      // Jika UI mengirim "L" atau "P" secara langsung, gunakan nilai tersebut
      genderCode = jenisKelamin;
    }

    final response = await ApiService.register(
      name: name,
      email: email,
      password: password,
      batchId: batchId,
      trainingId: trainingId,
      jenisKelamin: genderCode, // Kirim hasil mapping (L/P)
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = welcomeFromJson(response.body);

      final token = result.data?.token;
      if (token != null) {
        await AuthPreferences.saveToken(token);
      }

      return result;
    } else {
      final error = jsonDecode(response.body);

      // Mengambil detail error spesifik jika ada (opsional)
      String errorMessage = error["message"] ?? "Register gagal";

      // Jika backend mengirim detail error dalam object "errors"
      if (error["errors"] != null) {
        // Contoh: mengambil error pertama dari salah satu field
        var validationErrors = error["errors"] as Map<String, dynamic>;
        errorMessage = validationErrors.values.first[0].toString();
      }

      throw Exception(errorMessage);
    }
  }

  static Future<Welcome?> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.login(email: email, password: password);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = welcomeFromJson(response.body);

      final token = result.data?.token;
      if (token != null) {
        await AuthPreferences.saveToken(token);
      }

      return result;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error["message"] ?? "Login gagal");
    }
  }
}

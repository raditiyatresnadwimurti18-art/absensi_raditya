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
    required String jenisKelamin,
  }) async {
    // Mapping gender
    String genderCode = (jenisKelamin == "Perempuan") ? "P" : "L";

    final response = await ApiService.register(
      name: name,
      email: email,
      password: password,
      batchId: batchId,
      trainingId: trainingId,
      jenisKelamin: genderCode,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = welcomeFromJson(response.body);
      final token = result.data?.token;
      final userData = result.data?.user;

      if (token != null && userData != null) {
        // Simpan Map dari model User ke Preferences
        await AuthPreferences.saveAuthData(token, userData.toJson());
      }
      return result;
    } else {
      _handleError(response.body, "Register gagal");
      return null;
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
      final userData = result.data?.user;

      if (token != null && userData != null) {
        await AuthPreferences.saveAuthData(token, userData.toJson());
      }
      return result;
    } else {
      _handleError(response.body, "Login gagal");
      return null;
    }
  }

  // Fungsi pembantu untuk parsing error agar kode tidak duplikat
  static void _handleError(String responseBody, String defaultMessage) {
    try {
      final error = jsonDecode(responseBody);
      String errorMessage = error["message"] ?? defaultMessage;

      if (error["errors"] != null) {
        var validationErrors = error["errors"] as Map<String, dynamic>;
        // Ambil pesan validasi pertama jika ada
        errorMessage = validationErrors.values.first[0].toString();
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(
        e is Exception
            ? e.toString().replaceAll("Exception: ", "")
            : defaultMessage,
      );
    }
  }
}

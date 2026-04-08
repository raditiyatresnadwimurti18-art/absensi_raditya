import 'dart:convert';
import 'package:absensi_raditya/api/api_service.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'dart:io';

import 'package:absensi_raditya/models/profile_model.dart';

class ProfileController {
  // 1. Ambil Profil & Simpan ke Lokal
  static Future<Data> getProfile() async {
    String? token = await AuthPreferences.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    final response = await ApiService.getProfile(token: token);

    if (response.statusCode == 200) {
      // Menggunakan modelProfileFromJson yang kamu buat
      final modelProfile = modelProfileFromJson(response.body);

      if (modelProfile.data != null) {
        // Simpan data ke shared preferences (dalam bentuk Map)
        await AuthPreferences.saveUserData(modelProfile.data!.toJson());
        return modelProfile.data!;
      } else {
        throw Exception("Data user kosong");
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? "Gagal mengambil data profil");
    }
  }

  // 2. Update Foto & Nama (Real-time)
  static Future<String> editFoto({
    required String base64String,
    required String name,
  }) async {
    String? token = await AuthPreferences.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    // Menembak ke ApiService (Pastikan ApiService.updatePhoto sudah menerima parameter name)
    final response = await ApiService.updatePhoto(
      token: token,
      base64Image: base64String,
      name: name,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final modelProfile = modelProfileFromJson(response.body);

      if (modelProfile.data != null) {
        // Update storage lokal agar Nama dan Foto sinkron di seluruh aplikasi
        await AuthPreferences.saveUserData(modelProfile.data!.toJson());

        // Mengembalikan URL foto terbaru (menggunakan profilePhotoUrl dari model)
        return modelProfile.data!.profilePhotoUrl ?? "";
      }
      throw Exception("Gagal sinkronisasi data");
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? "Gagal memperbarui profil");
    }
  }

  // 3. Update Nama & Email saja
  static Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    String? token = await AuthPreferences.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    final response = await ApiService.updateProfile(
      token: token,
      name: name,
      email: email,
    );

    if (response.statusCode == 200) {
      final modelProfile = modelProfileFromJson(response.body);
      if (modelProfile.data != null) {
        await AuthPreferences.saveUserData(modelProfile.data!.toJson());
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? "Gagal memperbarui profil");
    }
  }
}

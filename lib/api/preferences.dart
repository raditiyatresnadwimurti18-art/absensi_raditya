import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  static const String _tokenKey = "token";
  static const String _isLoginKey = "is_login";
  static const String _userKey = "user_data";

  // SIMPAN TOKEN & DATA USER (Biasanya saat Login/Register)
  static Future<void> saveAuthData(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoginKey, true);
    // Pastikan userData yang dipassing adalah hasil dari data.toJson() model
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  // UPDATE DATA USER SAJA (Digunakan saat Edit Profil / Edit Foto)
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  // AMBIL DATA USER
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null && userStr.isNotEmpty) {
      try {
        return jsonDecode(userStr) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // AMBIL TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // CEK STATUS LOGIN
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoginKey) ?? false;
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoginKey, false);
    // Jika ingin membersihkan total: await prefs.clear();
  }

  // 1. MENGAMBIL HANYA URL FOTO
  static Future<String?> getProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);

    if (userStr != null && userStr.isNotEmpty) {
      try {
        final Map<String, dynamic> userData = jsonDecode(userStr);
        // Mengambil key profile_photo_url sesuai dengan ModelData kamu
        return userData['profile_photo_url'];
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // 2. MENGUPDATE HANYA URL FOTO (Gunakan ini setelah upload berhasil)
  static Future<void> updateProfilePhoto(String newUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);

    if (userStr != null && userStr.isNotEmpty) {
      try {
        Map<String, dynamic> userData = jsonDecode(userStr);
        // Update field URL saja
        userData['profile_photo_url'] = newUrl;
        // Simpan kembali Map yang sudah diperbarui
        await prefs.setString(_userKey, jsonEncode(userData));
      } catch (e) {
        print("Gagal update foto lokal: $e");
      }
    }
  }
}

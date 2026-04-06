import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  static const String _tokenKey = "token";
  static const String _isLoginKey = "is_login";
  static const String _userKey = "user_data";

  // SIMPAN TOKEN & DATA USER
  static Future<void> saveAuthData(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoginKey, true);
    // Simpan data user sebagai JSON String
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

  // LOGOUT (HAPUS SEMUA)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Gunakan clear() jika ingin menghapus semua data,
    // atau remove spesifik seperti di bawah agar data non-auth tetap ada
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoginKey, false);
  }
}

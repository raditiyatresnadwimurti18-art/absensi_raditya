import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  static const String _tokenKey = "token";
  static const String _isLoginKey = "is_login";

  // SIMPAN TOKEN
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoginKey, true);
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
    await prefs.remove(_tokenKey);
    await prefs.setBool(_isLoginKey, false);
  }
}

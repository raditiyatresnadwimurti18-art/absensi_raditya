import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // --------------------------------------------------------------------------
  // AUTH & PROFILE SECTION
  // --------------------------------------------------------------------------

  static Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    return await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"email": email, "password": password}),
    );
  }

  static Future<http.Response> register({
    required String name,
    required String email,
    required String password,
    required String batchId,
    required String trainingId,
    required String jenisKelamin,
  }) async {
    return await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "batch_id": batchId,
        "training_id": trainingId,
        "jenis_kelamin": jenisKelamin,
      }),
    );
  }

  static Future<http.Response> getProfile({required String token}) async {
    return await get("profile", token); // Sekarang memanggil 'get' public
  }

  static Future<http.Response> updateProfile({
    required String token,
    required String name,
    required String email,
  }) async {
    final url = Uri.parse("$baseUrl/profile");
    return await http.put(
      url,
      headers: _headers(token),
      body: jsonEncode({"name": name, "email": email}),
    );
  }

  static Future<http.Response> updatePhoto({
    required String token,
    required String base64Image,
    required String name,
  }) async {
    final url = Uri.parse("$baseUrl/profile/photo");
    return await http.put(
      url,
      headers: _headers(token),
      body: jsonEncode({
        "name": name,
        "profile_photo": "data:image/png;base64,$base64Image",
      }),
    );
  }

  // --------------------------------------------------------------------------
  // ATTENDANCE SECTION
  // --------------------------------------------------------------------------

  static Future<http.Response> getAttendanceToday(String token) async {
    return await get("absen/today", token);
  }

  // Digunakan oleh Controller untuk check-in, check-out, izin
  static Future<http.Response> postAttendance(
    String endpoint,
    String token,
    Map<String, dynamic> data,
  ) async {
    return await post(endpoint, token, data);
  }

  // --------------------------------------------------------------------------
  // PUBLIC HELPERS (Fungsi Utama yang digunakan Controller)
  // --------------------------------------------------------------------------

  // Fungsi GET utama yang digunakan oleh Controller
  static Future<http.Response> get(String endpoint, String token) async {
    return await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
  }

  // Fungsi POST utama yang digunakan oleh Controller
  static Future<http.Response> post(
    String endpoint,
    String token,
    Map<String, dynamic> data,
  ) async {
    return await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );
  }

  // --------------------------------------------------------------------------
  // PRIVATE HELPERS
  // --------------------------------------------------------------------------

  static Map<String, String> _headers(String token) {
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
  }

  static Future<http.Response> delete(
    String endpoint,
    String token,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    return await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
  }
}

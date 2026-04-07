import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ambil data absen hari ini
  static Future<http.Response> getAttendanceToday(String token) async {
    final url = Uri.parse("$baseUrl/absen/today");
    return await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
  }

  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // --------------------------------------------------------------------------
  // AUTH & PROFILE SECTION
  // --------------------------------------------------------------------------

  static Future<http.Response> register({
    required String name,
    required String email,
    required String password,
    required String batchId,
    required String trainingId,
    required String jenisKelamin,
  }) async {
    final url = Uri.parse("$baseUrl/register");
    return await http.post(
      url,
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

  static Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"email": email, "password": password}),
    );
  }

  // --------------------------------------------------------------------------
  // ATTENDANCE SECTION (DENGAN postAttendance)
  // --------------------------------------------------------------------------
  static Future<http.Response> postAttendance(
    String endpoint,
    String token,
    Map<String, dynamic> data,
  ) async {
    // Langsung baseUrl + endpoint (misal: /api/check-in)
    final url = Uri.parse("$baseUrl/$endpoint");

    return await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );
  }

  // Opsional: Jika Anda tetap ingin fungsi spesifik yang memanggil helper di atas
  static Future<http.Response> checkIn({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await postAttendance("check-in", token, data);
  }

  static Future<http.Response> checkOut({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await postAttendance("check-out", token, data);
  }

  // Update Nama Profil (PUT)
  static Future<http.Response> updateProfile({
    required String token,
    required String name,
  }) async {
    final url = Uri.parse("$baseUrl/profile");
    return await http.put(
      // Menggunakan PUT
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"name": name}),
    );
  }

  // Update Foto Profil (PUT dengan Method Spoofing)
  // Update Foto Profil menggunakan Base64 (JSON PUT)
  static Future<http.Response> updatePhotoBase64({
    required String token,
    required String base64Image,
  }) async {
    final url = Uri.parse("$baseUrl/profile/photo");
    return await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "profile_photo":
            "data:image/png;base64,$base64Image", // Format JSON kamu
      }),
    );
  }
}

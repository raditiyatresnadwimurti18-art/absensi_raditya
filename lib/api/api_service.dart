import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
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
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // REGISTER
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

  // LOGIN
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

  // GET PROFILE
  static Future<http.Response> getProfile(String token) async {
    final url = Uri.parse("$baseUrl/user");

    return await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
  }

  // UPDATE
  static Future<http.Response> updateProfile({
    required String token,
    required String name,
    required String email,
  }) async {
    final url = Uri.parse("$baseUrl/user");

    return await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"name": name, "email": email}),
    );
  }

  // DELETE
  static Future<http.Response> deleteUser(String token) async {
    final url = Uri.parse("$baseUrl/user");

    return await http.delete(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
  }

  //checkin dan checkout

  static Future<http.Response> checkIn({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse(
      "$baseUrl/attendance/check-in",
    ); // Sesuaikan endpoint API Anda
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

  static Future<http.Response> checkOut({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse(
      "$baseUrl/attendance/check-out",
    ); // Sesuaikan endpoint API Anda
    return await http.put(
      // Biasanya check-out menggunakan PUT/PATCH untuk update data hari yang sama
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );
  }
}

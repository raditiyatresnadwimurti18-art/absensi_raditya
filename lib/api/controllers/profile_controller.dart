import 'dart:convert';
import 'dart:io';
import 'package:absensi_raditya/api/api_service.dart';
import 'package:absensi_raditya/api/preferences.dart';

class ProfileController {
  Future<Map<String, dynamic>> updateUserName(String newName) async {
    try {
      String? token = await AuthPreferences.getToken();
      if (token == null)
        return {"success": false, "message": "Sesi habis, silakan login ulang"};

      final response = await ApiService.updateProfile(
        token: token,
        name: newName,
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic>? localData = await AuthPreferences.getUserData();
        if (localData != null) {
          localData['name'] = responseData['data']['name'];
          await AuthPreferences.saveAuthData(token, localData);
        }
        return {"success": true, "message": responseData['message']};
      }
      return {
        "success": false,
        "message": responseData['message'] ?? "Gagal update nama",
      };
    } catch (e) {
      return {"success": false, "message": "Kesalahan server: $e"};
    }
  }

  Future<Map<String, dynamic>> updateUserPhoto(String filePath) async {
    try {
      String? token = await AuthPreferences.getToken();
      if (token == null) return {"success": false, "message": "Sesi habis"};

      // Konversi file gambar ke Base64
      File imageFile = File(filePath);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);

      // Kirim sebagai JSON PUT
      final response = await ApiService.updatePhotoBase64(
        token: token,
        base64Image: base64String,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan URL foto baru yang diberikan server ke lokal
        String newPhotoUrl = responseData['data']['profile_photo'];
        Map<String, dynamic>? localData = await AuthPreferences.getUserData();
        if (localData != null) {
          localData['profile_photo'] = newPhotoUrl;
          await AuthPreferences.saveAuthData(token, localData);
        }
        return {"success": true, "message": responseData['message']};
      }
      return {
        "success": false,
        "message": responseData['message'] ?? "Gagal update foto",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }
}

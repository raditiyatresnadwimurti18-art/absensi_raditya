import '../models/user_model.dart';
import 'api_client.dart';

class ProfileService {
  ProfileService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserModel?> fetchProfile(String token) async {
    final response = await _apiClient.get('/profile', token: token);
    final profile = response['data'] ?? response['user'] ?? response['profile'];

    if (profile is! Map<String, dynamic>) {
      return null;
    }

    return UserModel.fromJson(profile);
  }

  Future<UserModel?> updateProfile({
    required String token,
    required String name,
    required String email,
  }) async {
    final response = await _apiClient.put(
      '/edit-profile',
      token: token,
      body: {
        'name': name,
        'email': email,
      },
    );

    final profile = response['data'] ?? response['user'] ?? response['profile'];
    if (profile is! Map<String, dynamic>) {
      return null;
    }

    return UserModel.fromJson(profile);
  }
}

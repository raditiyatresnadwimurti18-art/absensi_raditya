import '../models/auth_response_model.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    return AuthResponseModel.fromJson(response);
  }

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String batch,
    required int trainingId,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/register',
      body: {
        'name': name,
        'email': email,
        'batch': batch,
        'training_id': trainingId,
        'password': password,
      },
    );

    return AuthResponseModel.fromJson(response);
  }
}

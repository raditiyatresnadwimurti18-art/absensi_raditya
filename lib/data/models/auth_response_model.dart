import 'user_model.dart';

class AuthResponseModel {
  AuthResponseModel({
    required this.token,
    required this.user,
    required this.message,
  });

  final String token;
  final UserModel? user;
  final String message;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json['data'];

    return AuthResponseModel(
      token: (json['token'] ?? json['access_token'] ?? '').toString(),
      user: userJson is Map<String, dynamic> ? UserModel.fromJson(userJson) : null,
      message: (json['message'] ?? 'Berhasil').toString(),
    );
  }
}

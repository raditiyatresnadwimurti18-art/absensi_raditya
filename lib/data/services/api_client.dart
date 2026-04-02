import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String path, {
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.get(
      _buildUri(path, queryParameters),
      headers: _headers(token: token),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.post(
      _buildUri(path),
      headers: _headers(token: token),
      body: jsonEncode(body ?? {}),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.put(
      _buildUri(path),
      headers: _headers(token: token),
      body: jsonEncode(body ?? {}),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.delete(
      _buildUri(path, queryParameters),
      headers: _headers(token: token),
    );

    return _decodeResponse(response);
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final base = Uri.parse(AppConstants.baseUrl);

    return base.replace(
      path: '${base.path}$normalizedPath'.replaceAll('//', '/'),
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Map<String, String> _headers({String? token}) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic payload =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (payload is Map<String, dynamic>) {
        return payload;
      }

      return {'data': payload};
    }

    final message = payload is Map<String, dynamic>
        ? (payload['message'] ?? payload['error'] ?? 'Request gagal').toString()
        : 'Request gagal';
    throw ApiException(message);
  }
}

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

import '../models/attendance_model.dart';
import '../models/location_payload.dart';
import 'api_client.dart';

class AttendanceService {
  AttendanceService(this._apiClient);

  final ApiClient _apiClient;

  Future<AttendanceModel?> checkIn({
    required String token,
    required LocationPayload location,
  }) async {
    final response = await _apiClient.post(
      '/absen-check-in',
      token: token,
      body: {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    );

    final attendanceJson = _extractAttendance(response);
    return attendanceJson == null ? null : AttendanceModel.fromJson(attendanceJson);
  }

  Future<AttendanceModel?> checkOut({
    required String token,
    required LocationPayload location,
  }) async {
    final response = await _apiClient.post(
      '/absen-check-out',
      token: token,
      body: {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    );

    final attendanceJson = _extractAttendance(response);
    return attendanceJson == null ? null : AttendanceModel.fromJson(attendanceJson);
  }

  Future<List<AttendanceModel>> fetchHistory(String token) async {
    final response = await _apiClient.get('/history-absen', token: token);
    final list = response['data'] ?? response['history'] ?? response['absensi'] ?? [];

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map(AttendanceModel.fromJson)
        .toList();
  }

  Future<void> deleteAttendance({
    required String token,
    required int attendanceId,
  }) async {
    await _apiClient.delete(
      '/delete-absen',
      token: token,
      queryParameters: {'id': attendanceId},
    );
  }

  Map<String, dynamic>? _extractAttendance(Map<String, dynamic> response) {
    final data = response['data'] ?? response['attendance'] ?? response['absen'];
    return data is Map<String, dynamic> ? data : null;
  }
}

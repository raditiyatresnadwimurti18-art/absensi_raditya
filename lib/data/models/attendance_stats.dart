import 'attendance_model.dart';

class AttendanceStats {
  AttendanceStats({
    required this.totalAttendance,
    required this.totalCheckIn,
    required this.totalCheckOut,
    required this.todayAttendance,
  });

  final int totalAttendance;
  final int totalCheckIn;
  final int totalCheckOut;
  final AttendanceModel? todayAttendance;

  factory AttendanceStats.fromHistory(List<AttendanceModel> history) {
    final today = history.where((item) => item.isToday).toList();

    return AttendanceStats(
      totalAttendance: history.length,
      totalCheckIn: history.where((item) => item.checkIn != null).length,
      totalCheckOut: history.where((item) => item.checkOut != null).length,
      todayAttendance: today.isEmpty ? null : today.first,
    );
  }
}

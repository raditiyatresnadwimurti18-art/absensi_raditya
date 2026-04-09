import 'dart:convert';

AttendanceResponse attendanceResponseFromJson(String str) =>
    AttendanceResponse.fromJson(json.decode(str));

class AttendanceResponse {
  String? message;
  AttendanceData? data;

  AttendanceResponse({this.message, this.data});

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) =>
      AttendanceResponse(
        message: json["message"],
        data: json["data"] == null
            ? null
            : AttendanceData.fromJson(json["data"]),
      );
}

class AttendanceData {
  int? id;
  DateTime? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  String? status;
  String? alasanIzin;

  AttendanceData({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.alasanIzin,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) => AttendanceData(
    id: json["id"] is String ? int.tryParse(json["id"]) : json["id"],
    attendanceDate: json["attendance_date"] != null
        ? DateTime.parse(json["attendance_date"])
        : (json["date"] != null
              ? DateTime.parse(json["date"])
              : null), // Fallback ke "date"
    checkInTime: json["check_in_time"] ?? json["check_in"],
    checkOutTime: json["check_out_time"] ?? json["check_out"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );
}

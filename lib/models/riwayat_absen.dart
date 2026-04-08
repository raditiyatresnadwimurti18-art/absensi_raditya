import 'dart:convert';

HistoryResponse historyResponseFromJson(String str) =>
    HistoryResponse.fromJson(json.decode(str));

class HistoryResponse {
  String? message;
  List<HistoryData>? data;

  HistoryResponse({this.message, this.data});

  factory HistoryResponse.fromJson(Map<String, dynamic> json) =>
      HistoryResponse(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<HistoryData>.from(
                json["data"].map((x) => HistoryData.fromJson(x)),
              ),
      );
}

class HistoryData {
  int? id;
  String? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  String? status;
  String? alasanIzin;

  HistoryData({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.alasanIzin,
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) => HistoryData(
    id: json["id"],
    attendanceDate: json["attendance_date"],
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );
}

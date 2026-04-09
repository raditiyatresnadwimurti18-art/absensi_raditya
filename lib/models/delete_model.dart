import 'dart:convert';

DeleteModel deleteModelFromJson(String str) =>
    DeleteModel.fromJson(json.decode(str));
String deleteModelToJson(DeleteModel data) => json.encode(data.toJson());

class DeleteModel {
  String? message;
  Data? data;

  DeleteModel({this.message, this.data});

  factory DeleteModel.fromJson(Map<String, dynamic> json) => DeleteModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  int? id;
  int? userId;
  DateTime? checkIn;
  String? checkInLocation;
  String? checkInAddress;
  DateTime? checkOut;
  String? checkOutLocation;
  String? checkOutAddress;
  String? status;
  dynamic alasanIzin;
  DateTime? createdAt;
  DateTime? updatedAt;
  double? checkInLat;
  double? checkInLng;
  double? checkOutLat;
  double? checkOutLng;

  Data({
    this.id,
    this.userId,
    this.checkIn,
    this.checkInLocation,
    this.checkInAddress,
    this.checkOut,
    this.checkOutLocation,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    // Gunakan toInt() atau parsing yang aman untuk ID
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"].toString()),
    userId: json["user_id"] is int
        ? json["user_id"]
        : int.tryParse(json["user_id"].toString()),

    // PERBAIKAN: Jangan pakai DateTime.parse jika isinya cuma jam (HH:mm)
    // Jika API mengirim "2023-10-10 08:00:00" baru pakai DateTime
    checkIn:
        (json["check_in"] != null && json["check_in"].toString().contains("-"))
        ? DateTime.tryParse(json["check_in"])
        : null,

    checkInLocation: json["check_in_location"]?.toString(),
    checkInAddress: json["check_in_address"]?.toString(),

    checkOut:
        (json["check_out"] != null &&
            json["check_out"].toString().contains("-"))
        ? DateTime.tryParse(json["check_out"])
        : null,

    checkOutLocation: json["check_out_location"]?.toString(),
    checkOutAddress: json["check_out_address"]?.toString(),
    status: json["status"]?.toString(),
    alasanIzin: json["alasan_izin"],

    createdAt: json["created_at"] == null
        ? null
        : DateTime.tryParse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.tryParse(json["updated_at"]),

    // Pastikan koordinat selalu jadi double
    checkInLat: json["check_in_lat"] != null
        ? double.tryParse(json["check_in_lat"].toString())
        : null,
    checkInLng: json["check_in_lng"] != null
        ? double.tryParse(json["check_in_lng"].toString())
        : null,
    checkOutLat: json["check_out_lat"] != null
        ? double.tryParse(json["check_out_lat"].toString())
        : null,
    checkOutLng: json["check_out_lng"] != null
        ? double.tryParse(json["check_out_lng"].toString())
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "check_in": checkIn?.toIso8601String(),
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "check_out": checkOut?.toIso8601String(),
    "check_out_location": checkOutLocation,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
  };
}

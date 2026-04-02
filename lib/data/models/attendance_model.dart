class AttendanceModel {
  AttendanceModel({
    required this.id,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.latitude,
    this.longitude,
    this.address,
  });

  final int id;
  final DateTime? date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double? latitude;
  final double? longitude;
  final String? address;

  bool get isToday {
    if (date == null) {
      return false;
    }

    final now = DateTime.now();
    return date!.year == now.year &&
        date!.month == now.month &&
        date!.day == now.day;
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: _toInt(json['id']),
      date: _parseDateTime(
        json['date'] ??
            json['tanggal'] ??
            json['attendance_date'] ??
            json['created_at'],
      ),
      checkIn: _parseDateTime(
        json['check_in'] ??
            json['jam_masuk'] ??
            json['check_in_time'] ??
            json['checkin_at'],
      ),
      checkOut: _parseDateTime(
        json['check_out'] ??
            json['jam_keluar'] ??
            json['check_out_time'] ??
            json['checkout_at'],
      ),
      latitude: _toDouble(json['latitude'] ?? json['lat']),
      longitude: _toDouble(json['longitude'] ?? json['long'] ?? json['lng']),
      address: (json['address'] ?? json['lokasi'] ?? json['location'])?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}

class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.batch,
    this.trainingId,
    this.trainingName,
  });

  final int id;
  final String name;
  final String email;
  final String? batch;
  final int? trainingId;
  final String? trainingName;

  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isEmpty ? name : parts.first;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _toInt(json['id']),
      name: (json['name'] ?? json['nama'] ?? '-').toString(),
      email: (json['email'] ?? '-').toString(),
      batch: (json['batch'] ?? json['angkatan'])?.toString(),
      trainingId: _tryToInt(json['training_id'] ?? json['id_training']),
      trainingName: (json['training_name'] ?? json['training'] ?? json['pelatihan'])
          ?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _tryToInt(dynamic value) {
    if (value == null) {
      return null;
    }

    return int.tryParse(value.toString());
  }
}

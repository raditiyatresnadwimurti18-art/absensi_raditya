import 'dart:convert';

// Fungsi untuk konversi dari string JSON ke model Welcome
Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

// Fungsi untuk konversi dari model Welcome ke string JSON
String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  String? message;
  Data? data;

  Welcome({this.message, this.data});

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    message: json["message"],
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  String? token;
  User? user;

  Data({this.token, this.user});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"],
    user: json["user"] != null ? User.fromJson(json["user"]) : null,
  );

  Map<String, dynamic> toJson() => {"token": token, "user": user?.toJson()};
}

class User {
  int? id;
  String? name;
  String? email;
  String? batchId;
  String? trainingId;
  String? jenisKelamin;
  String? profilePhoto;
  Batch? batch;
  Training? training;

  User({
    this.id,
    this.name,
    this.email,
    this.batchId,
    this.trainingId,
    this.jenisKelamin,
    this.profilePhoto,
    this.batch,
    this.training,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    batchId: json["batch_id"]
        ?.toString(), // Ambil sebagai string untuk keamanan
    trainingId: json["training_id"]?.toString(),
    jenisKelamin: json["jenis_kelamin"],
    profilePhoto: json["profile_photo"],
    batch: json["batch"] != null ? Batch.fromJson(json["batch"]) : null,
    training: json["training"] != null
        ? Training.fromJson(json["training"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "batch_id": batchId,
    "training_id": trainingId,
    "jenis_kelamin": jenisKelamin,
    "profile_photo": profilePhoto,
    "batch": batch?.toJson(),
    "training": training?.toJson(),
  };
}

class Batch {
  int? id;
  String? batchKe;
  String? startDate;
  String? endDate;

  Batch({this.id, this.batchKe, this.startDate, this.endDate});

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
    id: json["id"],
    batchKe: json["batch_ke"],
    startDate: json["start_date"],
    endDate: json["end_date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "batch_ke": batchKe,
    "start_date": startDate,
    "end_date": endDate,
  };
}

class Training {
  int? id;
  String? title;
  String? description;

  Training({this.id, this.title, this.description});

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json["id"],
    title: json["title"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
  };
}

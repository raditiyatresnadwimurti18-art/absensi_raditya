import 'package:absensi_raditya/models/training_model.dart';

class BatchModel {
  final int id;
  final String batchKe;
  final String startDate;
  final String endDate;
  final List<TrainingModel> trainings;

  BatchModel({
    required this.id,
    required this.batchKe,
    required this.startDate,
    required this.endDate,
    required this.trainings,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    // Memetakan list training di dalam batch
    var list = json['trainings'] as List;
    List<TrainingModel> trainingList = list
        .map((i) => TrainingModel.fromJson(i))
        .toList();

    return BatchModel(
      id: json['id'],
      batchKe: json['batch_ke'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      trainings: trainingList,
    );
  }
}

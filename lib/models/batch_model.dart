// lib/models/batch_model.dart

import 'dart:convert';
// import 'package:absensi_maps/models/training_model.dart'; // Jika BatchData berisi Training model, pastikan Training model sudah diimpor

BatchResponse batchResponseFromJson(String str) =>
    BatchResponse.fromJson(json.decode(str));
String batchResponseToJson(BatchResponse data) => json.encode(data.toJson());

class BatchResponse {
  String? message;
  List<BatchData>? data;

  BatchResponse({this.message, this.data});

  factory BatchResponse.fromJson(Map<String, dynamic> json) => BatchResponse(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<BatchData>.from(
                json["data"].map((x) => BatchData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class BatchData {
  int id; // <--- UBAH DARI int? menjadi int (asumsi ID selalu ada)
  String? batchKe;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  // List<Training>? trainings; // Jika tidak diperlukan, hapus

  BatchData({
    required this.id, // Pastikan required
    this.batchKe,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    // this.trainings, // Jika tidak diperlukan, hapus dari konstruktor
  });

  factory BatchData.fromJson(Map<String, dynamic> json) => BatchData(
        id: json["id"] as int, // <--- Parse sebagai int non-nullable
        batchKe: json["batch_ke"] as String?,
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        endDate:
            json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        // trainings: json["trainings"] == null
        //     ? []
        //     : List<Training>.from(
        //         json["trainings"].map((x) => Training.fromJson(x)),
        //       ),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "batch_ke": batchKe,
        "start_date": startDate?.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        // "trainings": trainings == null
        //     ? []
        //     : List<dynamic>.from(trainings!.map((x) => x.toJson())),
      };
}
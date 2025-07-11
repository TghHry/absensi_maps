// lib/models/training_model.dart

import 'dart:convert';

ListJurusan listJurusanFromJson(String str) =>
    ListJurusan.fromJson(json.decode(str));

String listJurusanToJson(ListJurusan data) => json.encode(data.toJson());

class ListJurusan {
  String message;
  List<Datum> data;

  ListJurusan({required this.message, required this.data});

  factory ListJurusan.fromJson(Map<String, dynamic> json) => ListJurusan(
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int id; // Asumsi ID selalu ada
  String? title;
  String? description;
  Pivot? pivot;
  int? participantCount; // Tambahkan ini jika ada di API

  Datum({
    required this.id,
    this.title,
    this.description,
    this.pivot,
    this.participantCount,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] as int, // Parse sebagai int non-nullable
        title: json["title"] as String?,
        description: json["description"] as String?,
        pivot: json["pivot"] == null
            ? null
            : Pivot.fromJson(json["pivot"] as Map<String, dynamic>),
        participantCount: json["participant_count"] as int?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "pivot": pivot?.toJson(),
        "participant_count": participantCount,
      };
}

class Pivot {
  String? trainingBatchId;
  String? trainingId;

  Pivot({
    this.trainingBatchId,
    this.trainingId,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
        trainingBatchId: json["training_batch_id"] as String?,
        trainingId: json["training_id"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "training_batch_id": trainingBatchId,
        "training_id": trainingId,
      };
}
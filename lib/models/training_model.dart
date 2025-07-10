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
  int id; // Dibuat nullable agar sesuai contoh API (jika ID bisa null atau string)
  String? title; // Dibuat nullable
  String? description; // <-- TAMBAHKAN INI
  Pivot? pivot; // <-- TAMBAHKAN INI (jika API Anda mengembalikan objek pivot untuk training)
  int? participantCount; // <-- Tambahkan ini jika respons API Anda untuk training memiliki properti ini.
                        // Saya menambahkannya sebagai placeholder karena Anda menggunakannya di profile_page sebelumnya.

  Datum({
    required this.id,
    this.title,
    this.description, // Tambahkan ke konstruktor
    this.pivot, // Tambahkan ke konstruktor
    this.participantCount, // Tambahkan ke konstruktor
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] as int, // Casting aman ke int?
        title: json["title"] as String?, // Casting aman ke String?
        description: json["description"] as String?, // <-- PARSING INI
        pivot: json["pivot"] == null // <-- PARSING INI
            ? null
            : Pivot.fromJson(json["pivot"] as Map<String, dynamic>),
        participantCount: json["participant_count"] == null // <-- PARSING INI jika tersedia
            ? null
            : json["participant_count"] as int?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description, // Tambahkan ke toJson
        "pivot": pivot?.toJson(), // Tambahkan ke toJson
        "participant_count": participantCount, // Tambahkan ke toJson
      };
}

// Definisikan kelas Pivot jika belum ada di file ini atau file yang di-share
class Pivot {
  // Asumsi ini adalah string dari respons API berdasarkan kode Anda sebelumnya
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
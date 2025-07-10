// lib/presentation/absensi/profile/models/profile_model.dart

import 'dart:convert';
import 'package:absensi_maps/models/batch_model.dart'; // Untuk BatchData
import 'package:absensi_maps/models/training_model.dart'; // Untuk Datum

// Helper untuk parse dari JSON string
ProfileResponse profileResponseFromJson(String str) => ProfileResponse.fromJson(json.decode(str));

// Helper untuk konversi ke JSON string
String profileResponseToJson(ProfileResponse data) => json.encode(data.toJson());

class ProfileResponse {
    final String message;
    final ProfileUser? data; // Bisa null jika ada error atau data tidak ditemukan

    ProfileResponse({
        required this.message,
        this.data,
    });

    factory ProfileResponse.fromJson(Map<String, dynamic> json) => ProfileResponse(
        message: json["message"] as String,
        data: json["data"] == null ? null : ProfileUser.fromJson(json["data"] as Map<String, dynamic>),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
    };
}

class ProfileUser {
    final int id;
    final String name;
    final String email;
    final DateTime? emailVerifiedAt;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? batchId;
    final int? trainingId;
    final String? jenisKelamin;
    final String? profilePhoto;
    final String? onesignalPlayerId;
    final BatchData? batch; // Menggunakan BatchData dari batch_model.dart
    final Datum? training; // Menggunakan Datum dari training_model.dart

    // Properti tambahan yang di-flatten dari batch dan training untuk kemudahan akses di UI
    String? get batchKe => batch?.batchKe;
    DateTime? get batchStartDate => batch?.startDate;
    DateTime? get batchEndDate => batch?.endDate;
    String? get trainingTitle => training?.title;
    String? get trainingDescription => training?.description;
    // Tambahan untuk training jika ada di API, contoh:
    int? get trainingParticipantCount => training?.pivot?.trainingId != null ? 1 : null; // Ini contoh, sesuaikan jika ada participant_count di API

    ProfileUser({
        required this.id,
        required this.name,
        required this.email,
        this.emailVerifiedAt,
        this.createdAt,
        this.updatedAt,
        this.batchId,
        this.trainingId,
        this.jenisKelamin,
        this.profilePhoto,
        this.onesignalPlayerId,
        this.batch,
        this.training,
    });

    factory ProfileUser.fromJson(Map<String, dynamic> json) => ProfileUser(
        id: json["id"] as int,
        name: json["name"] as String,
        email: json["email"] as String,
        emailVerifiedAt: json["email_verified_at"] == null ? null : DateTime.parse(json["email_verified_at"] as String),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"] as String),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"] as String),
        batchId: json["batch_id"] == null ? null : int.tryParse(json["batch_id"].toString()),
        trainingId: json["training_id"] == null ? null : int.tryParse(json["training_id"].toString()),
        jenisKelamin: json["jenis_kelamin"] as String?,
        profilePhoto: json["profile_photo"] as String?,
        onesignalPlayerId: json["onesignal_player_id"] as String?,
        batch: json["batch"] == null ? null : BatchData.fromJson(json["batch"] as Map<String, dynamic>),
        training: json["training"] == null ? null : Datum.fromJson(json["training"] as Map<String, dynamic>),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "batch_id": batchId,
        "training_id": trainingId,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": profilePhoto,
        "onesignal_player_id": onesignalPlayerId,
        "batch": batch?.toJson(),
        "training": training?.toJson(),
    };
}
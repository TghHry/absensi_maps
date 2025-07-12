// lib/presentation/absensi/profile/models/profile_model.dart

import 'dart:convert';
import 'package:absensi_maps/models/batch_model.dart'; // Untuk BatchData
import 'package:absensi_maps/models/training_model.dart'; // Untuk Datum
import 'package:absensi_maps/api/api_service.dart'; // <<< Pastikan ini diimport untuk akses ApiService.baseUrl

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
    final DateTime? createdAt; // Tetap nullable
    final DateTime? updatedAt; // Tetap nullable
    final int? batchId;
    final int? trainingId;
    final String? jenisKelamin;
    final String? profilePhoto; // Ini adalah path relatif dari API
    final String? onesignalPlayerId;
    final BatchData? batch;
    final Datum? training;

    // Properti tambahan yang di-flatten dari batch dan training
    String? get batchKe => batch?.batchKe;
    DateTime? get batchStartDate => batch?.startDate;
    DateTime? get batchEndDate => batch?.endDate;
    String? get trainingTitle => training?.title;
    String? get trainingDescription => training?.description;
    int? get trainingParticipantCount => training?.pivot?.trainingId != null ? 1 : null;

    // <<< PERBAIKAN PENTING DI SINI: SESUAIKAN URL FOTO DENGAN HASIL POSTMAN >>>
    String? get fullProfilePhotoUrl {
        if (profilePhoto == null || profilePhoto!.isEmpty) {
            return null; // Jika tidak ada foto atau path kosong, kembalikan null
        }
        
        // Cek apakah profilePhoto sudah absolute URL (dimulai dengan http/https)
        if (profilePhoto!.startsWith('http://') || profilePhoto!.startsWith('https://')) {
            return profilePhoto; // Jika sudah URL lengkap dari API, langsung pakai
        }
        
        // Berdasarkan hasil Postman Anda, URL yang berhasil diakses adalah
        // https://appabsensi.mobileprojp.com/public/profile_photo/budianduks_1752381689.png
        // Ini berarti kita perlu menggabungkan ApiService.baseUrl dengan '/public/' dan path foto.
        const String publicStorageSegment = '/public/'; // Ini adalah segmen yang kurang
        
        // Pastikan profilePhoto tidak dimulai dengan '/' jika publicStorageSegment sudah punya '/'
        String cleanedPhotoPath = profilePhoto!.startsWith('/') ? profilePhoto!.substring(1) : profilePhoto!;
        
        return ApiService.baseUrl + publicStorageSegment + cleanedPhotoPath;
    }
    // <<< AKHIR PERBAAIKAN GETTER >>>


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

    factory ProfileUser.fromJson(Map<String, dynamic> json) {
        DateTime? _tryParseDateTime(dynamic value) {
            if (value == null) return null;
            try {
                return DateTime.parse(value.toString());
            } catch (e) {
                return null;
            }
        }

        return ProfileUser(
            id: json["id"] as int,
            name: json["name"] as String,
            email: json["email"] as String,
            emailVerifiedAt: _tryParseDateTime(json["email_verified_at"]),
            createdAt: _tryParseDateTime(json["created_at"]),
            updatedAt: _tryParseDateTime(json["updated_at"]),
            batchId: json["batch_id"] == null ? null : int.tryParse(json["batch_id"].toString()),
            trainingId: json["training_id"] == null ? null : int.tryParse(json["training_id"].toString()),
            jenisKelamin: json["jenis_kelamin"] as String?,
            profilePhoto: json["profile_photo"] as String?, // Ini adalah path relatif dari API
            onesignalPlayerId: json["onesignal_player_id"] as String?,
            batch: json["batch"] == null ? null : BatchData.fromJson(json["batch"] as Map<String, dynamic>),
            training: json["training"] == null ? null : Datum.fromJson(json["training"] as Map<String, dynamic>),
        );
    }

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
        "profile_photo": profilePhoto, // Kirim path relatif saat toJson
        "onesignal_player_id": onesignalPlayerId,
        "batch": batch?.toJson(),
        "training": training?.toJson(),
    };
}
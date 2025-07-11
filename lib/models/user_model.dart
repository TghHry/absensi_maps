// lib/models/user_model.dart

// import 'dart:convert'; // Sudah ada di beberapa model lain
import 'package:absensi_maps/utils/datetime_users.dart'; // Impor helper DateTime
import 'package:absensi_maps/models/batch_model.dart'; // Import BatchData
import 'package:absensi_maps/models/training_model.dart'; // Import Datum (untuk training)

class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? batchId; // Tambahkan ini
  final int? trainingId; // Tambahkan ini
  final String? jenisKelamin; // Tambahkan ini
  final String? profilePhotoPath; // Tambahkan ini
  final String? onesignalPlayerId; // Tambahkan ini
  final BatchData? batch; // Tambahkan ini
  final Datum? training; // Tambahkan ini, atau buat model Training yang lebih spesifik jika Datum tidak cukup

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.batchId, // Diperlukan di konstruktor
    this.trainingId, // Diperlukan di konstruktor
    this.jenisKelamin, // Diperlukan di konstruktor
    this.profilePhotoPath, // Diperlukan di konstruktor
    this.onesignalPlayerId, // Diperlukan di konstruktor
    this.batch, // Diperlukan di konstruktor
    this.training, // Diperlukan di konstruktor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] != null
          ? tryParseDateTime(json['email_verified_at'] as String)
          : null,
      createdAt: tryParseDateTime(json['created_at'] as String)!,
      updatedAt: tryParseDateTime(json['updated_at'] as String)!,
      batchId: json['batch_id'] != null ? int.tryParse(json['batch_id'].toString()) : null,
      trainingId: json['training_id'] != null ? int.tryParse(json['training_id'].toString()) : null,
      jenisKelamin: json['jenis_kelamin'] as String?,
      profilePhotoPath: json['profile_photo'] as String?,
      onesignalPlayerId: json['onesignal_player_id'] as String?,
      batch: json['batch'] == null ? null : BatchData.fromJson(json['batch'] as Map<String, dynamic>),
      training: json['training'] == null ? null : Datum.fromJson(json['training'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'batch_id': batchId,
      'training_id': trainingId,
      'jenis_kelamin': jenisKelamin,
      'profile_photo': profilePhotoPath,
      'onesignal_player_id': onesignalPlayerId,
      'batch': batch?.toJson(),
      'training': training?.toJson(),
    };
  }
}
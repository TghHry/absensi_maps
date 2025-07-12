// lib/models/user_model.dart

import 'dart:convert'; // Untuk jsonEncode/jsonDecode
import 'package:absensi_maps/models/batch_model.dart'; // Untuk BatchData
import 'package:absensi_maps/models/training_model.dart'; // Untuk Datum (training)
// Asumsi Anda memiliki helper untuk DateTime parsing, jika tidak, bisa gunakan DateTime.parse langsung
// import 'package:absensi_maps/utils/datetime_users.dart'; // Jika ini digunakan, ganti _tryParseDateTime internal

class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt; // Properti non-nullable
  final DateTime updatedAt; // Properti non-nullable
  final int? batchId;
  final int? trainingId;
  final String? jenisKelamin;
  final String? profilePhotoPath;
  final String? onesignalPlayerId;
  final BatchData? batch;
  final Datum? training;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt, // Wajib ada
    required this.updatedAt, // Wajib ada
    this.batchId,
    this.trainingId,
    this.jenisKelamin,
    this.profilePhotoPath,
    this.onesignalPlayerId,
    this.batch,
    this.training,
  });

  // Factory constructor untuk membuat objek User dari Map (misalnya dari JSON API)
  factory User.fromJson(Map<String, dynamic> json) {
    // Helper function untuk parsing DateTime secara aman
    // Ini adalah versi internal, jika Anda punya datetime_users.dart, pastikan untuk menggunakannya
    DateTime? _tryParseDateTime(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        // Anda bisa menambahkan debugPrint di sini jika ingin melacak error parsing DateTime
        // debugPrint('User.fromJson: Error parsing DateTime "$value": $e');
        return null;
      }
    }

    // --- PERBAIKAN UTAMA DI SINI ---
    // Gunakan operator ?? untuk memberikan nilai fallback jika hasil parse adalah null
    final DateTime parsedCreatedAt = _tryParseDateTime(json['created_at']) ?? DateTime(2000, 1, 1, 0, 0, 0, 0, 0); // Default ke 1 Jan 2000
    final DateTime parsedUpdatedAt = _tryParseDateTime(json['updated_at']) ?? DateTime(2000, 1, 1, 0, 0, 0, 0, 0); // Default ke 1 Jan 2000

    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: _tryParseDateTime(json['email_verified_at']),
      createdAt: parsedCreatedAt, // Gunakan hasil parse yang sudah aman
      updatedAt: parsedUpdatedAt, // Gunakan hasil parse yang sudah aman
      batchId: json['batch_id'] != null ? int.tryParse(json['batch_id'].toString()) : null,
      trainingId: json['training_id'] != null ? int.tryParse(json['training_id'].toString()) : null,
      jenisKelamin: json['jenis_kelamin'] as String?,
      profilePhotoPath: json['profile_photo'] as String?, // Ini sudah aman karena String?
      onesignalPlayerId: json['onesignal_player_id'] as String?,
      batch: json['batch'] == null ? null : BatchData.fromJson(json['batch'] as Map<String, dynamic>),
      training: json['training'] == null ? null : Datum.fromJson(json['training'] as Map<String, dynamic>),
    );
  }

  // Metode untuk mengkonversi objek User ke Map (misalnya untuk disimpan sebagai JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(), // Ini aman karena createdAt di sini selalu non-null
      'updated_at': updatedAt.toIso8601String(), // Ini aman karena updatedAt di sini selalu non-null
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
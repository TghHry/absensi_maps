// File: lib/models/user_base_model.dart

import 'package:flutter/foundation.dart'; // Untuk debugPrint di helper _tryParseDateTime

// Helper function untuk parsing DateTime yang fleksibel
DateTime? _tryParseDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    try {
      if (dateString.length == 19 && dateString.contains(' ')) {
        return DateTime.parse(dateString.replaceFirst(' ', 'T') + 'Z');
      }
    } catch (e2) {
      debugPrint('Warning: Could not parse date string "$dateString": $e2');
    }
  }
  return null;
}

// Model pengguna dasar
// Digunakan dalam respons login dan registrasi (karena hanya butuh data dasar)
// Dan sebagai bagian dasar dari model profil yang lebih kompleks.
class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] != null
          ? _tryParseDateTime(json['email_verified_at'] as String)
          : null,
      createdAt: _tryParseDateTime(json['created_at'] as String)!,
      updatedAt: _tryParseDateTime(json['updated_at'] as String)!,
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
    };
  }
}
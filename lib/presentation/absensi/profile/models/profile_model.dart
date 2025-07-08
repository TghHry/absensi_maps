import 'dart:convert';

import 'package:absensi_maps/presentation/absensi/auth/login/models/login_model.dart';



// Model untuk objek 'data' dari API response profil
// Ini pada dasarnya sama dengan User, tapi bisa digunakan untuk konsistensi penamaan
class ProfileData {
  final User user; // Menggunakan model User yang sudah ada

  ProfileData({
    required this.user,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    // Perhatikan bahwa di JSON Anda, objek 'data' langsung berisi properti user.
    // Jadi, kita langsung passing json itu ke User.fromJson
    return ProfileData(
      user: User.fromJson(json), // Langsung parse JSON 'data' sebagai User
    );
  }

  Map<String, dynamic> toJson() {
    return user.toJson(); // Langsung kembalikan representasi JSON dari User
  }
}

// Model untuk keseluruhan response API profil
class ProfileResponse {
  final String message;
  final ProfileData data; // Menggunakan ProfileData

  ProfileResponse({
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      message: json['message'] as String,
      // Perhatikan bahwa di JSON Anda, 'data' langsung berisi objek user.
      // Jadi, kita passing 'json['data']' ke ProfileData.fromJson.
      // ProfileData.fromJson kemudian akan menganggap json['data'] sebagai objek User.
      data: ProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

// --- Contoh penggunaan model ini di fungsi main() sementara atau di file test ---
void main() {
  final String jsonString = """
  {
      "message": "Berhasil mengambil data profil pengguna",
      "data": {
          "id": 1,
          "name": "Budi",
          "email": "budi@example.com",
          "email_verified_at": null,
          "created_at": "2025-04-10T07:01:59.000000Z",
          "updated_at": "2025-04-10T07:01:59.000000Z"
      }
  }
  """;

  final Map<String, dynamic> jsonMap = json.decode(jsonString);

  // Deserialize JSON ke Dart object
  final ProfileResponse response = ProfileResponse.fromJson(jsonMap);

  print('Pesan: ${response.message}');
  print('ID Pengguna: ${response.data.user.id}');
  print('Nama Pengguna: ${response.data.user.name}');
  print('Email Pengguna: ${response.data.user.email}');
  print('Email Verified At: ${response.data.user.emailVerifiedAt}');
  print('Dibuat Pada: ${response.data.user.createdAt}');
  print('Diperbarui Pada: ${response.data.user.updatedAt}');

  // Serialize Dart object kembali ke JSON (opsional)
  final Map<String, dynamic> serializedJson = response.toJson();
  print('\nJSON Serialized: ${json.encode(serializedJson)}');
}
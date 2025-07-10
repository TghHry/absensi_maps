// lib/models/login_response_model.dart

import 'dart:convert';
import 'package:absensi_maps/models/user_model.dart'; // Import User model Anda
import 'package:flutter/foundation.dart'; // Untuk debugPrint

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));
String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  final String message;
  final String? token; // Token bisa null jika login gagal
  final User? user;    // Objek User bisa null jika login gagal

  LoginResponse({
    required this.message,
    this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Ambil objek 'data' terlebih dahulu jika ada
    final Map<String, dynamic>? dataJson = json["data"] as Map<String, dynamic>?;

    // Sekarang, parsing token dan user dari dataJson
    return LoginResponse(
      message: json["message"] as String,
      token: dataJson?["token"] as String?, // <-- PERBAIKAN DI SINI
      user: dataJson?["user"] == null
          ? null
          : User.fromJson(dataJson!["user"] as Map<String, dynamic>), // <-- PERBAIKAN DI SINI
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "token": token,
        "user": user?.toJson(),
      };
}
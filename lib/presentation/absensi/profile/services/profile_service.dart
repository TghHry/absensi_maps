// File: lib/services/profile_service.dart

import 'dart:convert';
import 'dart:io'; // Untuk SocketException
// import 'package:absensi_maps/presentation/absensi/profile/models/profile_model.dart';
import 'package:absensi_maps/presentation/absensi/profile/models/profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint
// KOREKSI IMPORT MODEL PROFIL INI
// Pastikan file 'profile_models.dart' Anda berisi ProfileResponse, EditProfileResponse, ProfileUser, dll.
// Jika Anda juga perlu mengakses kelas User dasar secara langsung di service ini,
// tambahkan import berikut:
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk mendapatkan token
class ProfileService {
  final String _baseUrl = 'https://appabsensi.mobileprojp.com/'; // Pastikan ini URL API Anda
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Helper untuk mendapatkan token dari FlutterSecureStorage
  Future<String> _getToken() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
    }
    return token;
  }

  /// Mengambil data profil pengguna dari API.
  /// Endpoint: GET {{base_url}}/api/profile
  Future<ProfileResponse> fetchUserProfile() async {
    final token = await _getToken();
    final url = Uri.parse('${_baseUrl}api/profile');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('URL Permintaan Profil (GET): $url');
    debugPrint('Header Permintaan Profil (GET): $headers');

    try {
      final response = await http.get(url, headers: headers);
      debugPrint('Kode Status Respon Profil (GET): ${response.statusCode}');
      debugPrint('Body Respon Profil (GET): ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return ProfileResponse.fromJson(jsonResponse); // Mem-parse ke ProfileResponse
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.');
      } else {
        Map<String, dynamic> errorResponse = {};
        try { if (response.body.isNotEmpty) errorResponse = json.decode(response.body); } catch (e) { /* ignore */ }
        final String errorMessage = errorResponse['message'] ?? 'Gagal mengambil data profil.';
        throw Exception('Error: $errorMessage (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga saat mengambil profil: ${e.toString()}');
    }
  }

  /// Memperbarui data profil pengguna di API.
  /// Endpoint: PUT {{base_url}}/api/profile
  Future<EditProfileResponse> updateUserProfile(String name, String email) async {
    final token = await _getToken();
    final url = Uri.parse('${_baseUrl}api/profile');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'name': name,
      'email': email,
    });

    debugPrint('URL Permintaan Update Profil (PUT): $url');
    debugPrint('Header Permintaan Update Profil (PUT): $headers');
    debugPrint('Body Permintaan Update Profil (PUT): $body');

    try {
      final response = await http.put(url, headers: headers, body: json.encode(body));

      debugPrint('Kode Status Respon Update Profil (PUT): ${response.statusCode}');
      debugPrint('Body Respon Update Profil (PUT): ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return EditProfileResponse.fromJson(jsonResponse); // Mem-parse ke EditProfileResponse
      } else if (response.statusCode == 422) {
        Map<String, dynamic> errorResponse = json.decode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Data yang Anda masukkan tidak valid.';
        if (errorResponse.containsKey('errors') && errorResponse['errors'] is Map) {
          (errorResponse['errors'] as Map).forEach((key, value) {
            if (value is List) errorMessage += '\n${key.toUpperCase()}: ${value.join(', ')}';
          });
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.');
      } else {
        String serverMessage = 'Terjadi kesalahan pada server saat memperbarui profil. Mohon coba lagi.';
        try { if (response.body.isNotEmpty) serverMessage = json.decode(response.body)['message'] ?? serverMessage; } catch (e) { /* ignore */ }
        throw Exception('$serverMessage (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda atau coba lagi nanti.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga saat update profil: ${e.toString()}');
    }
  }
}
// File: lib/services/profile_service.dart

import 'dart:convert';
import 'package:absensi_maps/presentation/absensi/edit_profile/models.dart/edit_profile_model.dart';
import 'package:absensi_maps/presentation/absensi/profile/models/profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint

// Import model-model yang diperlukan.
// Pastikan file ini berisi definisi untuk User, ProfileData, ProfileResponse, dan EditProfileResponse.

class ProfileService {
  // Base URL untuk API Anda. Ganti dengan URL dasar yang benar.
  final String _baseUrl = 'https://appabsensi.mobileprojp.com/';

  /// Mengambil data profil pengguna dari API.
  Future<ProfileResponse> fetchUserProfile(String token) async {
    final url = Uri.parse('${_baseUrl}api/user'); // Asumsi endpoint GET profil
    final headers = {
      'Content-Type': 'application/json',
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
        return ProfileResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.',
        );
      } else {
        Map<String, dynamic> errorResponse = {};
        try {
          errorResponse = json.decode(response.body);
        } catch (e) {
          /* ignore */
        }
        final String errorMessage =
            errorResponse['message'] ??
            'Gagal mengambil data profil. Mohon coba lagi.';
        throw Exception(
          'Error: $errorMessage (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error selama pengambilan profil: $e');
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    }
  }

  /// Memperbarui data profil pengguna di API.
  ///
  /// Menerima [token] otentikasi, [name] baru, dan [email] baru sebagai input.
  /// Mengembalikan objek [EditProfileResponse] jika berhasil.
  /// Melemparkan [Exception] jika terjadi kegagalan.
  Future<EditProfileResponse> updateUserProfile(
    String token,
    String name,
    String email,
  ) async {
    // Asumsi endpoint PUT untuk update profil adalah sama dengan GET profil, yaitu '/api/user'
    final url = Uri.parse('${_baseUrl}api/user');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'name': name,
      'email': email,
      // Anda mungkin juga perlu menyertakan bidang lain yang relevan seperti 'phone_number'
      // jika API Anda mengharapkannya dan Anda ingin memperbaruinya.
      // 'phone_number': phoneNumber,
    });

    debugPrint('URL Permintaan Update Profil (PUT): $url');
    debugPrint('Header Permintaan Update Profil (PUT): $headers');
    debugPrint('Body Permintaan Update Profil (PUT): $body');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body,
      ); // Menggunakan http.put

      debugPrint(
        'Kode Status Respon Update Profil (PUT): ${response.statusCode}',
      );
      debugPrint('Body Respon Update Profil (PUT): ${response.body}');

      if (response.statusCode == 200) {
        // Jika berhasil (OK)
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return EditProfileResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Jika token tidak valid atau expired
        throw Exception(
          'Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.',
        );
      } else if (response.statusCode == 422) {
        // Kode umum untuk error validasi
        Map<String, dynamic> errorResponse = {};
        try {
          errorResponse = json.decode(response.body);
        } catch (e) {
          /* ignore */
        }

        String errorMessage =
            errorResponse['message'] ?? 'Data yang Anda masukkan tidak valid.';
        if (errorResponse.containsKey('errors')) {
          // Jika ada detail error validasi, gabungkan
          (errorResponse['errors'] as Map).forEach((key, value) {
            errorMessage +=
                '\n${key.toUpperCase()}: ${value[0]}'; // Ambil pesan pertama dari list error
          });
        }
        throw Exception(errorMessage);
      } else {
        // Tangani kesalahan lain dari server
        Map<String, dynamic> errorResponse = {};
        try {
          errorResponse = json.decode(response.body);
        } catch (e) {
          /* ignore */
        }
        final String errorMessage =
            errorResponse['message'] ??
            'Gagal memperbarui profil. Mohon coba lagi.';
        throw Exception(
          'Error: $errorMessage (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error selama update profil: $e');
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda atau coba lagi nanti.',
      );
    }
  }
}

// --- Contoh penggunaan layanan ini di fungsi main() (untuk demonstrasi) ---
void main() async {
  final profileService = ProfileService();

  // Anda perlu menyediakan token otentikasi yang valid di sini.
  // Dalam aplikasi nyata, token ini akan diambil dari penyimpanan lokal (FlutterSecureStorage)
  const String validToken =
      'YOUR_AUTH_TOKEN_HERE'; // Ganti dengan token yang sebenarnya

  // Variabel 'existingEmail' dihapus karena tidak digunakan.
  const String newName = 'Budi Santoso Updated';
  const String newEmail =
      'budi.updated@example.com'; // Pastikan ini unik jika API Anda mengharuskan

  if (validToken == 'YOUR_AUTH_TOKEN_HERE') {
    debugPrint(
      'PERINGATAN: Ganti YOUR_AUTH_TOKEN_HERE dengan token yang valid untuk pengujian.',
    );
    return;
  }

  debugPrint('\n--- Mencoba Mengambil Profil Pengguna ---');
  try {
    final profileResponse = await profileService.fetchUserProfile(validToken);
    debugPrint(
      'Profil Pengguna Saat Ini: ${profileResponse.data.user.name}, ${profileResponse.data.user.email}',
    );
  } catch (e) {
    debugPrint('Gagal mengambil profil awal: $e');
  }

  debugPrint('\n--- Mencoba Memperbarui Profil Pengguna ---');
  try {
    debugPrint(
      'Memperbarui profil menjadi Nama: "$newName", Email: "$newEmail"',
    );
    // Memanggil updateUserProfile dengan token, nama baru, dan email baru
    final updatedProfile = await profileService.updateUserProfile(
      validToken,
      newName,
      newEmail,
    );

    debugPrint('Profil Pengguna Berhasil Diperbarui!');
    debugPrint('Pesan: ${updatedProfile.message}');
    debugPrint('Nama Baru: ${updatedProfile.data.name}');
    debugPrint('Email Baru: ${updatedProfile.data.email}');
  } catch (e) {
    debugPrint('Pembaruan Profil Gagal: $e');
  }
}

// File: lib/services/login_service.dart

import 'dart:convert';
import 'package:absensi_maps/presentation/absensi/auth/login/models/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint

// Import model-model yang diperlukan.
// Ganti 'package:absensi_maps/models/auth_models.dart' sesuai dengan lokasi file Anda.

class LoginService {
  // Ganti dengan URL API sebenarnya Anda
  final String _baseUrl =
      'https://appabsensi.mobileprojp.com/'; // Contoh: 'https://your-backend.com/api'

  /// Melakukan proses login pengguna.
  ///
  /// Menerima [email] dan [password] sebagai input.
  /// Mengembalikan [LoginResponse] jika berhasil, atau melempar exception jika gagal.
  Future<LoginResponse> loginUser(String email, String password) async {
    final url = Uri.parse(
      '${_baseUrl}api/login',
    ); // Asumsi endpoint login adalah /api/login
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'email': email, 'password': password});

    debugPrint('URL Permintaan Login: $url');
    debugPrint('Body Permintaan Login: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      debugPrint('Kode Status Respon Login: ${response.statusCode}');
      debugPrint('Body Respon Login: ${response.body}');

      if (response.statusCode == 200) {
        // Asumsi kode 200 untuk login berhasil
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return LoginResponse.fromJson(jsonResponse);
      } else {
        // Tangani respon non-200 (misalnya, kredensial salah, error server)
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        // Coba ambil pesan error dari API, default ke 'Email atau password salah'
        throw Exception(
          'Gagal login: ${errorResponse['message'] ?? 'Email atau password salah'}',
        );
      }
    } catch (e) {
      debugPrint('Error selama login: $e');
      rethrow; // Lempar kembali exception agar ditangani oleh pemanggil
    }
  }
}

// --- Contoh penggunaan layanan ini di fungsi main() (untuk demonstrasi) ---
void main() async {
  final loginService = LoginService();

  debugPrint('\n--- Mencoba Login Pengguna ---');
  const String testEmail =
      'budi@example.com'; // Ganti dengan email yang valid di API Anda
  const String testPassword = 'password'; // Ganti dengan password yang benar

  try {
    debugPrint('Mencoba login dengan email: $testEmail');
    final loginResponse = await loginService.loginUser(testEmail, testPassword);

    debugPrint('Login Pengguna Berhasil!');
    debugPrint('Pesan: ${loginResponse.message}');
    debugPrint('Token: ${loginResponse.data.token}');
    debugPrint('ID Pengguna: ${loginResponse.data.user.id}');
    debugPrint('Nama Pengguna: ${loginResponse.data.user.name}');
    debugPrint('Email Pengguna: ${loginResponse.data.user.email}');
  } catch (e) {
    debugPrint('Login Pengguna Gagal: $e');
  }
}

// lib/api/api_service.dart

import 'dart:convert';
import 'package:absensi_maps/models/batch_model.dart';
import 'package:absensi_maps/models/training_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// Tambahkan import model respons API yang baru (AttendanceApiResponse)
// Perhatikan path ini, sesuaikan jika modelnya di lokasi lain
import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_api_service.dart'; // <<< Perbaikan Path Import (seharusnya models/, bukan services/)

class ApiService {
  static const String baseUrl = 'https://appabsensi.mobileprojp.com';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String tokenKey = 'auth_token';

  /// Saves the authentication token securely.
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: tokenKey, value: token);
    debugPrint('ApiService: Token saved securely.');
  }

  /// Retrieves the authentication token securely.
  static Future<String?> getToken() async {
    String? token = await _secureStorage.read(key: tokenKey);
    debugPrint('ApiService: Token retrieved: $token');
    return token;
  }

  /// Deletes the authentication token securely.
  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: tokenKey);
    debugPrint('ApiService: Token deleted securely.');
  }

  static Map<String, String> _getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Endpoint: /api/profile (Untuk mengambil data user terbaru)
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final uri = Uri.parse('$baseUrl/api/profile');
    debugPrint('ApiService: Fetching profile from: $uri');
    try {
      final response = await http.get(uri, headers: _getHeaders(token: token));

      debugPrint('ApiService: Profile API response status: ${response.statusCode}');
      debugPrint('ApiService: Profile API response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal memuat profil. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error fetching profile: $e');
      throw Exception('ApiService: Terjadi kesalahan saat memuat profil: $e');
    }
  }

  /// Endpoint: /api/profile (Untuk update data profil: nama, email)
  static Future<Map<String, dynamic>> updateProfileData({
    required String token,
    required String name,
    String? email,
  }) async {
    final uri = Uri.parse('$baseUrl/api/profile');
    Map<String, dynamic> body = {
      'name': name,
      if (email != null) 'email': email,
    };
    debugPrint('ApiService: Mengirim UPDATE PROFILE DENGAN BODY: ${jsonEncode(body)}');
    try {
      final response = await http.put(
        uri,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );
      debugPrint('ApiService: Update profile data API response status: ${response.statusCode}');
      debugPrint('ApiService: Update profile data API response body: ${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal memperbarui profil. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error updating profile data: $e');
      throw Exception('ApiService: Terjadi kesalahan saat memperbarui data profil: $e');
    }
  }

  /// Endpoint: /api/profile/photo (Untuk update foto profil)
  static Future<Map<String, dynamic>> updateProfilePhoto({
    required String token,
    required String base64Photo,
  }) async {
    final uri = Uri.parse('$baseUrl/api/profile/photo');
    final body = {'profile_photo': 'data:image/png;base64,$base64Photo'}; // Menggunakan 'data:image/png;base64,' prefix
    debugPrint('ApiService: Updating profile photo to: $uri with body: $body');
    try {
      final response = await http.put(
        uri,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );
      debugPrint('ApiService: Update profile photo API response status: ${response.statusCode}');
      debugPrint('ApiService: Update profile photo API response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal memperbarui foto profil. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error updating profile photo: $e');
      throw Exception('ApiService: Terjadi kesalahan saat memperbarui foto profil: $e');
    }
  }

  /// Endpoint: /api/login
  static Future<Map<String, dynamic>> login( // Perbaikan: Pastikan method ini ada dan konsisten
    String email,
    String password,
  ) async {
    final uri = Uri.parse('$baseUrl/api/login'); // Gunakan baseUrl yang baru
    debugPrint('ApiService: Logging in to: $uri with email: $email');
    try {
      final response = await http.post(
        uri,
        headers: _getHeaders(), // Tidak perlu token untuk login
        body: jsonEncode({'email': email, 'password': password}),
      );
      debugPrint('ApiService: Login API response status: ${response.statusCode}');
      debugPrint('ApiService: Login API response body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception( // Throw Exception untuk error agar bisa ditangkap di layer service/UI
          errorData['message'] ?? 'Login gagal. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error during login: $e');
      throw Exception('ApiService: Terjadi kesalahan saat login: $e'); // Throw error untuk penanganan di atas
    }
  }

  /// Endpoint: /api/register (Diperbarui dengan parameter lengkap)
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int trainingId,
    required int batchId,
    String? profilePhoto,
  }) async {
    final uri = Uri.parse('$baseUrl/api/register');
    Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'password': password,
      'jenis_kelamin': jenisKelamin,
      'training_id': trainingId,
      'batch_id': batchId,
    };
    if (profilePhoto != null) {
      body['profile_photo'] = profilePhoto;
    }
    debugPrint('ApiService: Registering to: $uri with body: ${jsonEncode(body)}');
    try {
      final response = await http.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      debugPrint('ApiService: Register API response status: ${response.statusCode}');
      debugPrint('ApiService: Register API response body: ${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Registrasi gagal. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error during registration: $e');
      throw Exception('ApiService: Terjadi kesalahan saat registrasi: $e');
    }
  }

  /// --- FUNGSI GETTRAININGS DIPERBARUI ---
  static Future<ListJurusan> getTrainings() async {
    final uri = Uri.parse('$baseUrl/api/trainings');
    debugPrint('ApiService: Fetching trainings from: $uri');
    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      debugPrint('ApiService: Trainings API response status: ${response.statusCode}');
      debugPrint('ApiService: Trainings API response body: ${response.body}');

      if (response.statusCode == 200) {
        return listJurusanFromJson(response.body);
      } else {
        throw Exception(
          'Gagal memuat data training. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error fetching trainings: $e');
      throw Exception('ApiService: Terjadi kesalahan saat memuat data training: $e');
    }
  }

  /// Endpoint: /api/batches (Publik, sesuai pembaruan)
  static Future<BatchResponse> getBatches() async {
    final uri = Uri.parse('$baseUrl/api/batches');
    debugPrint('ApiService: Fetching batches from: $uri');
    try {
      final response = await http.get(uri, headers: _getHeaders());
      debugPrint('ApiService: Batches API response status: ${response.statusCode}');
      debugPrint('ApiService: Batches API response body: ${response.body}');
      if (response.statusCode == 200) {
        return batchResponseFromJson(response.body);
      } else {
        throw Exception(
          'Gagal memuat data batch. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error fetching batches: $e');
      throw Exception('ApiService: Terjadi kesalahan saat memuat data batch: $e');
    }
  }

  /// Endpoint: /api/izin (Baru)
  static Future<Map<String, dynamic>> submitIzin({
    required String token,
    required String date,
    required String reason,
  }) async {
    final uri = Uri.parse('$baseUrl/api/izin');
    final body = {'date': date, 'alasan_izin': reason};
    debugPrint('ApiService: Submitting izin to: $uri with body: ${jsonEncode(body)}');
    try {
      final response = await http.post(
        uri,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );
      debugPrint('ApiService: Submit Izin API response status: ${response.statusCode}');
      debugPrint('ApiService: Submit Izin API response body: ${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal mengajukan izin. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error submitting izin: $e');
      throw Exception('ApiService: Terjadi kesalahan saat mengajukan izin: $e');
    }
  }

  /// Endpoint: /api/absen/check-in
  // Perbaikan signature: Hapus ', required String status, required String statuse' yang salah
  static Future<Map<String, dynamic>> checkIn({
    required String token,
    required double latitude,
    required double longitude,
    required String address,
    required String status, // Menambahkan parameter status
  }) async {
    final uri = Uri.parse('$baseUrl/api/absen/check-in');

    final now = DateTime.now();
    final String currentDate = DateFormat('yyyy-MM-dd').format(now);
    final String currentTime = DateFormat('HH:mm').format(now);

    Map<String, dynamic> body = {
      'check_in_lat': latitude.toString(),
      'check_in_lng': longitude.toString(),
      'check_in_address': address,
      'status': status, // Gunakan status yang diterima
      'attendance_date': currentDate,
      'check_in': currentTime,
    };
    debugPrint('ApiService: Checking in to: $uri with body: ${jsonEncode(body)}');
    try {
      final response = await http.post(
        uri,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );
      debugPrint('ApiService: Check-in API response status: ${response.statusCode}');
      debugPrint('ApiService: Check-in API response body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Check-in gagal. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error during check-in: $e');
      throw Exception('ApiService: Terjadi kesalahan saat check-in: $e');
    }
  }

  /// Endpoint: /api/absen/check-out
  static Future<Map<String, dynamic>> checkOut({
    required String token,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final uri = Uri.parse('$baseUrl/api/absen/check-out');

    final now = DateTime.now();
    final String currentDate = DateFormat('yyyy-MM-dd').format(now);
    final String currentTime = DateFormat('HH:mm').format(now);

    final body = {
      'check_out_lat': latitude.toString(),
      'check_out_lng': longitude.toString(),
      'check_out_address': address,
      'attendance_date': currentDate,
      'check_out': currentTime,
    };
    debugPrint('ApiService: Checking out to: $uri with body: ${jsonEncode(body)}');
    try {
      final response = await http.post(
        uri,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );
      debugPrint('ApiService: Check-out API response status: ${response.statusCode}');
      debugPrint('ApiService: Check-out API response body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Check-out gagal. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error during check-out: $e');
      throw Exception('ApiService: Terjadi kesalahan saat check-out: $e');
    }
  }

  /// Endpoint: /api/absen/today
  // PERBAIKAN PENTING: Menangani 404 sebagai kondisi data 'null', bukan error
  static Future<Map<String, dynamic>> getTodayAttendance(String token) async {
    final uri = Uri.parse('$baseUrl/api/absen/today');
    debugPrint('ApiService: Fetching today attendance from: $uri');
    try {
      final response = await http.get(uri, headers: _getHeaders(token: token));
      debugPrint('ApiService: Today Attendance API response status: ${response.statusCode}');
      debugPrint('ApiService: Today Attendance API response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // Ini adalah kasus spesifik dari API Anda: 404 berarti "belum ada data"
        final responseBody = json.decode(response.body);
        if (responseBody['message'] == "Belum ada data absensi pada tanggal tersebut" &&
            responseBody['data'] == null) {
          // Kembalikan sebagai respons sukses dengan data null
          debugPrint('ApiService: 404 diinterpretasikan sebagai "no data" untuk hari ini.');
          return {
            "message": responseBody['message'],
            "data": null, // Penting: Data diatur null
          };
        } else {
          // Jika 404 tapi dengan pesan/struktur yang tidak diharapkan, lempar sebagai error
          throw Exception(
            responseBody['message'] ?? 'Gagal memuat status absensi hari ini. Status: ${response.statusCode}',
          );
        }
      } else {
        // Untuk status kode error lainnya (misal 401, 500)
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal memuat status absensi hari ini. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error fetching today attendance: $e');
      throw Exception('ApiService: Terjadi kesalahan saat memuat status absensi hari ini: $e');
    }
  }

  /// Endpoint: /api/absen/stats (Untuk statistik di HomeScreen)
  static Future<Map<String, dynamic>> getAbsenStats(String token) async {
    final uri = Uri.parse('$baseUrl/api/absen/stats');
    debugPrint('ApiService: Fetching attendance stats from: $uri');
    try {
      final response = await http.get(uri, headers: _getHeaders(token: token));
      debugPrint('ApiService: Attendance Stats API response status: ${response.statusCode}');
      debugPrint('ApiService: Attendance Stats API response body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal memuat statistik absensi. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error fetching attendance stats: $e');
      throw Exception('ApiService: Terjadi kesalahan saat memuat statistik absensi: $e');
    }
  }

  /// Endpoint: /api/absen/history
  static Future<Map<String, dynamic>> getHistory(
    String token, {
    String? startDate,
    String? endDate,
  }) async {
    var uri = Uri.parse('$baseUrl/api/absen/history');
    if (startDate != null && endDate != null) {
      uri = uri.replace(queryParameters: {'start': startDate, 'end': endDate});
    }
    debugPrint('ApiService: Fetching history from: $uri');
    try {
      final response = await http.get(uri, headers: _getHeaders(token: token));
      debugPrint('ApiService: History API response status: ${response.statusCode}');
      debugPrint('ApiService: History API response body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal memuat riwayat absensi. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error fetching history: $e');
      throw Exception('ApiService: Terjadi kesalahan saat memuat riwayat absensi: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteAttendance({
    required String token,
    required int id,
  }) async {
    final uri = Uri.parse('$baseUrl/api/absen/$id');
    debugPrint('ApiService: Mengirim DELETE request ke: $uri');
    try {
      final response = await http.delete(
        uri,
        headers: _getHeaders(token: token),
      );

      debugPrint('ApiService: Delete Attendance API response status: ${response.statusCode}');
      debugPrint('ApiService: Delete Attendance API response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal menghapus data absen. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ApiService: Error saat menghapus absensi: $e');
      throw Exception('ApiService: Terjadi kesalahan jaringan/server saat menghapus absensi: $e');
    }
  }
}
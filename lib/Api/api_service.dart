import 'dart:convert';
import 'package:absensi_maps/models/batch_model.dart';
import 'package:absensi_maps/models/training_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart'; // PASTIKAN IMPORT INI ADA

class ApiService {
  static const String _baseUrl = 'https://appabsensi.mobileprojp.com';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String tokenKey = 'auth_token';

  /// Saves the authentication token securely.
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: tokenKey, value: token);
    debugPrint('Token saved securely.');
  }

  /// Retrieves the authentication token securely.
  static Future<String?> getToken() async {
    String? token = await _secureStorage.read(key: tokenKey);
    debugPrint('Token retrieved: $token');
    return token;
  }

  /// Deletes the authentication token securely.
  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: tokenKey);
    debugPrint('Token deleted securely.');
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
    final uri = Uri.parse('$_baseUrl/api/profile');
    debugPrint('Fetching profile from: $uri');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Profile API response status: ${response.statusCode}');
      debugPrint('Profile API response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {'message': errorData['message'] ?? 'Gagal memuat profil'};
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return {'message': 'Terjadi kesalahan: $e'};
    }
  }

  /// Endpoint: /api/profile/photo (Untuk update foto profil)
  static Future<Map<String, dynamic>> updateProfilePhoto({
    required String token,
    required String base64Photo,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/profile/photo');
    final body = {'profile_photo': 'data:image/png;base64,$base64Photo'};
    debugPrint('Updating profile photo to: $uri with body: $body');
    final response = await http.put(
      uri,
      headers: _getHeaders(token: token),
      body: jsonEncode(body),
    );
    debugPrint(
      'Update profile photo API response status: ${response.statusCode}',
    );
    debugPrint('Update profile photo API response body: ${response.body}');
    return json.decode(response.body);
  }

  /// Endpoint: /api/profile (Untuk update data profil selain foto)
  static Future<Map<String, dynamic>> updateProfileData({
    required String token,
    required String name,
    // Hapus parameter jenisKelamin, trainingId, batchId dari sini
  }) async {
    final uri = Uri.parse('$_baseUrl/api/profile');
    Map<String, dynamic> body = {
      'name': name, // Hanya kirim 'name'
    };
    debugPrint(
      'ApiService: Mengirim UPDATE PROFILE DENGAN BODY: ${jsonEncode(body)}',
    );
    final response = await http.put(
      uri,
      headers: _getHeaders(token: token),
      body: jsonEncode(body),
    );
    debugPrint(
      'ApiService: Update profile data API response status: ${response.statusCode}',
    );
    debugPrint(
      'ApiService: Update profile data API response body: ${response.body}',
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal memperbarui profil.');
    }
  }
  
  /// Endpoint: /api/login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/login');
    debugPrint('Logging in to: $uri with email: $email');
    final response = await http.post(
      uri,
      headers: _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    debugPrint('Login API response status: ${response.statusCode}');
    debugPrint('Login API response body: ${response.body}');
    return jsonDecode(response.body);
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
    final uri = Uri.parse('$_baseUrl/api/register');
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
    debugPrint('Registering to: $uri with body: $body');

    final response = await http.post(
      uri,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
    debugPrint('Register API response status: ${response.statusCode}');
    debugPrint('Register API response body: ${response.body}');
    return json.decode(response.body);
  }

  /// --- FUNGSI GETTRAININGS DIPERBARUI ---
  static Future<ListJurusan> getTrainings() async {
    final uri = Uri.parse('$_baseUrl/api/trainings');
    debugPrint('Fetching trainings from: $uri');
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    debugPrint('Trainings API response status: ${response.statusCode}');
    debugPrint('Trainings API response body: ${response.body}');

    if (response.statusCode == 200) {
      return listJurusanFromJson(response.body);
    } else {
      throw Exception('Gagal memuat data training');
    }
  }

  /// Endpoint: /api/batches (Publik, sesuai pembaruan)
  static Future<BatchResponse> getBatches() async {
    final uri = Uri.parse('$_baseUrl/api/batches');
    debugPrint('Fetching batches from: $uri');
    final response = await http.get(uri, headers: _getHeaders());
    debugPrint('Batches API response status: ${response.statusCode}');
    debugPrint('Batches API response body: ${response.body}');
    if (response.statusCode == 200) {
      return batchResponseFromJson(response.body);
    } else {
      throw Exception('Gagal memuat data batch');
    }
  }

  /// Endpoint: /api/izin (Baru)
  static Future<Map<String, dynamic>> submitIzin({
    required String token,
    required String date,
    required String reason,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/izin');
    final body = {'date': date, 'alasan_izin': reason};
    debugPrint('Submitting izin to: $uri with body: $body');
    final response = await http.post(
      uri,
      headers: _getHeaders(token: token),
      body: jsonEncode(body),
    );
    debugPrint('Submit Izin API response status: ${response.statusCode}');
    debugPrint('Submit Izin API response body: ${response.body}');
    return json.decode(response.body);
  }

  /// Endpoint: /api/absen/check-in
  static Future<Map<String, dynamic>> checkIn({
    required String token,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/absen/check-in');

    final now = DateTime.now();
    final String currentDate = DateFormat('yyyy-MM-dd').format(now);
    final String currentTime = DateFormat(
      'HH:mm',
    ).format(now); // <-- Format HH:mm

    Map<String, dynamic> body = {
      'check_in_lat': latitude.toString(),
      'check_in_lng': longitude.toString(),
      'check_in_address': address,
      'status': 'masuk',
      'attendance_date': currentDate,
      'check_in': currentTime,
    };
    debugPrint('Checking in to: $uri with body: $body');
    final response = await http.post(
      uri,
      headers: _getHeaders(token: token),
      body: jsonEncode(body),
    );
    debugPrint('Check-in API response status: ${response.statusCode}');
    debugPrint('Check-in API response body: ${response.body}');
    return jsonDecode(response.body);
  }

  /// Endpoint: /api/absen/check-out
  static Future<Map<String, dynamic>> checkOut({
    required String token,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/absen/check-out');

    final now = DateTime.now();
    final String currentDate = DateFormat('yyyy-MM-dd').format(now);
    final String currentTime = DateFormat(
      'HH:mm',
    ).format(now); // <-- Format HH:mm

    final body = {
      'check_out_lat': latitude.toString(),
      'check_out_lng': longitude.toString(),
      'check_out_address': address,
      'attendance_date': currentDate,
      'check_out': currentTime,
    };
    debugPrint('Checking out to: $uri with body: $body');
    final response = await http.post(
      uri,
      headers: _getHeaders(token: token),
      body: jsonEncode(body),
    );
    debugPrint('Check-out API response status: ${response.statusCode}');
    debugPrint('Check-out API response body: ${response.body}');
    return jsonDecode(response.body);
  }

  /// Endpoint: /api/absen/today
  static Future<Map<String, dynamic>> getTodayAttendance(String token) async {
    final uri = Uri.parse('$_baseUrl/api/absen/today');
    debugPrint('Fetching today attendance from: $uri');
    final response = await http.get(uri, headers: _getHeaders(token: token));
    debugPrint('Today Attendance API response status: ${response.statusCode}');
    debugPrint('Today Attendance API response body: ${response.body}');
    return jsonDecode(response.body);
  }

  /// Endpoint: /api/absen/stats (Untuk statistik di HomeScreen)
  static Future<Map<String, dynamic>> getAbsenStats(String token) async {
    final uri = Uri.parse('$_baseUrl/api/absen/stats');
    debugPrint('Fetching attendance stats from: $uri');
    final response = await http.get(uri, headers: _getHeaders(token: token));
    debugPrint('Attendance Stats API response status: ${response.statusCode}');
    debugPrint('Attendance Stats API response body: ${response.body}');
    return jsonDecode(response.body);
  }

  /// Endpoint: /api/absen/history
  static Future<Map<String, dynamic>> getHistory(
    String token, {
    String? startDate,
    String? endDate,
  }) async {
    var uri = Uri.parse('$_baseUrl/api/absen/history');
    if (startDate != null && endDate != null) {
      uri = uri.replace(queryParameters: {'start': startDate, 'end': endDate});
    }
    debugPrint('Fetching history from: $uri');
    final response = await http.get(uri, headers: _getHeaders(token: token));
    debugPrint('History API response status: ${response.statusCode}');
    debugPrint('History API response body: ${response.body}');
    return jsonDecode(response.body);
  }

 static Future<Map<String, dynamic>> deleteAttendance({
  required String token,
  required int id, // ID dari record absensi yang akan dihapus
}) async {
  final uri = Uri.parse('$_baseUrl/api/absen/$id'); // Endpoint DELETE: /api/absen/{id}
  debugPrint('ApiService: Mengirim DELETE request ke: $uri');
  try {
    final response = await http.delete(
      uri,
      // Gunakan _getHeaders untuk konsistensi
      headers: _getHeaders(token: token), // Perbaikan: Gunakan _getHeaders
    );

    debugPrint('ApiService: Delete Attendance API response status: ${response.statusCode}');
    debugPrint('ApiService: Delete Attendance API response body: ${response.body}');

    // Perbaikan: Lakukan check status code di ApiService juga
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      // Lempar Exception dengan pesan dari API jika ada, atau pesan default
      throw Exception(errorData['message'] ?? 'Gagal menghapus data absen. Status: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('ApiService: Error saat menghapus absensi: $e');
    throw Exception('Terjadi kesalahan jaringan/server saat menghapus absensi: $e'); // Lempar error untuk ditangani lebih lanjut
  }
}
}

// File: lib/services/attendance_service.dart

import 'dart:convert';
import 'dart:io'; // Untuk SocketException
import 'package:absensi_maps/presentation/absensi/attandance/models/attandance_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:geolocator/geolocator.dart'; // Untuk mendapatkan lokasi
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk mengambil token

class AttendanceService {
  final String _baseUrl = 'https://appabsensi.mobileprojp.com/'; // Ganti dengan URL API Anda
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Helper untuk mendapatkan token
  Future<String> _getToken() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
    }
    return token;
  }

  // Helper untuk mendapatkan lokasi saat ini
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak diaktifkan. Mohon aktifkan GPS Anda.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak. Mohon izinkan akses lokasi.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak secara permanen. Mohon ubah di pengaturan aplikasi.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// Melakukan proses Check In.
  /// Status bisa 'masuk' atau 'izin'.
  /// Jika status 'izin', 'alasanIzin' wajib diisi.
  Future<AttendanceResponse> checkIn({
    required String status,
    String? alasanIzin, // Hanya jika status 'izin'
  }) async {
    final token = await _getToken();
    final position = await _getCurrentLocation(); // Dapatkan lokasi
    
    // TODO: Dapatkan alamat sebenarnya dari Geocoding jika API mendukung
    // Saat ini, kita hardcode "Jakarta" seperti di Postman
    final String checkAddress = "Jakarta"; 

    final url = Uri.parse('${_baseUrl}api/absen/check-in');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> body = {
      'check_in_lat': position.latitude.toString(),
      'check_in_lng': position.longitude.toString(),
      'check_address': checkAddress,
      'status': status,
    };

    if (status == 'izin') {
      if (alasanIzin == null || alasanIzin.isEmpty) {
        throw Exception('Alasan izin wajib diisi jika status adalah "izin".');
      }
      body['alasan_izin'] = alasanIzin;
    }

    debugPrint('Permintaan Check In URL: $url');
    debugPrint('Permintaan Check In Headers: $headers');
    debugPrint('Permintaan Check In Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: json.encode(body));

      debugPrint('Status Code Respon Check In: ${response.statusCode}');
      debugPrint('Body Respon Check In: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return AttendanceResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 422) { // Error validasi
        Map<String, dynamic> errorResponse = json.decode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Data tidak valid.';
        if (errorResponse.containsKey('errors') && errorResponse['errors'] is Map) {
          (errorResponse['errors'] as Map).forEach((key, value) {
            if (value is List) errorMessage += '\n${key.toUpperCase()}: ${value.join(', ')}';
          });
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.');
      } else {
        String serverMessage = 'Terjadi kesalahan pada server saat Check In. Mohon coba lagi.';
        try {
          if (response.body.isNotEmpty) {
            Map<String, dynamic> errorJson = json.decode(response.body);
            serverMessage = errorJson['message'] ?? serverMessage;
          }
        } catch (e) { /* ignore */ }
        throw Exception('$serverMessage (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga saat Check In: ${e.toString()}');
    }
  }

  /// Melakukan proses Check Out.
  Future<AttendanceResponse> checkOut() async {
    final token = await _getToken();
    final position = await _getCurrentLocation(); // Dapatkan lokasi
    final String checkAddress = "Jakarta"; // TODO: Dapatkan alamat sebenarnya

    final url = Uri.parse('${_baseUrl}api/absen/check-out');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = {
      'check_out_lat': position.latitude.toString(),
      'check_out_lng': position.longitude.toString(),
      'check_out_address': checkAddress,
    };

    debugPrint('Permintaan Check Out URL: $url');
    debugPrint('Permintaan Check Out Headers: $headers');
    debugPrint('Permintaan Check Out Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: json.encode(body));

      debugPrint('Status Code Respon Check Out: ${response.statusCode}');
      debugPrint('Body Respon Check Out: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return AttendanceResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 422) { // Error validasi
        Map<String, dynamic> errorResponse = json.decode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Data tidak valid.';
        if (errorResponse.containsKey('errors') && errorResponse['errors'] is Map) {
          (errorResponse['errors'] as Map).forEach((key, value) {
            if (value is List) errorMessage += '\n${key.toUpperCase()}: ${value.join(', ')}';
          });
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.');
      } else {
        String serverMessage = 'Terjadi kesalahan pada server saat Check Out. Mohon coba lagi.';
        try {
          if (response.body.isNotEmpty) {
            Map<String, dynamic> errorJson = json.decode(response.body);
            serverMessage = errorJson['message'] ?? serverMessage;
          }
        } catch (e) { /* ignore */ }
        throw Exception('$serverMessage (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga saat Check Out: ${e.toString()}');
    }
  }

  // TODO: Tambahkan metode untuk mendapatkan status absensi hari ini (GET Absen Today)
  // Future<AttendanceRecord?> getTodayAttendance() async { ... }

  // TODO: Tambahkan metode untuk mendapatkan riwayat absensi (GET History Absen)
  // Future<List<AttendanceRecord>> getAttendanceHistory() async { ... }
}
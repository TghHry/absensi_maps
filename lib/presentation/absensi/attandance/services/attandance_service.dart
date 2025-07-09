// File: lib/services/attendance_service.dart
// (Pastikan sudah sesuai dengan ini, termasuk import-import yang diperlukan)

import 'dart:convert';
import 'dart:io';
import 'package:absensi_maps/presentation/absensi/attandance/models/attandance_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AttendanceService {
  final String _baseUrl =
      'https://appabsensi.mobileprojp.com/'; // Ganti dengan URL API Anda
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String> _getToken() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
    }
    return token;
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Layanan lokasi tidak diaktifkan. Mohon aktifkan GPS Anda.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak. Mohon izinkan akses lokasi.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak secara permanen. Mohon ubah di pengaturan aplikasi.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Metode untuk GET Absen Today (tetap sama)
  Future<AttendanceRecord?> getTodayAttendance() async {
    final token = await _getToken();
    final url = Uri.parse('${_baseUrl}api/absen/today');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    debugPrint('Permintaan Absen Today URL: $url');
    try {
      final response = await http.get(url, headers: headers);
      debugPrint('Status Code Respon Absen Today: ${response.statusCode}');
      debugPrint('Body Respon Absen Today: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data'] != null
            ? AttendanceRecord.fromJson(jsonResponse['data'])
            : null;
      } else if (response.statusCode == 404 &&
          response.body.contains("Belum ada data absensi hari ini")) {
        return null; // API mengembalikan 404 tapi artinya belum absen
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.',
        );
      } else {
        Map<String, dynamic> errorResponse = {};
        try {
          if (response.body.isNotEmpty)
            errorResponse = json.decode(response.body);
        } catch (e) {
          /* ignore */
        }
        throw Exception(
          'Error: ${errorResponse['message'] ?? 'Gagal mengambil status absen hari ini.'} (Status: ${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }

  // Metode untuk GET Absen Stats (tetap sama)
  Future<AbsenStatsResponse> getAbsenStats() async {
    final token = await _getToken();
    final url = Uri.parse('${_baseUrl}api/absen/stats');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    debugPrint('Permintaan Absen Stats URL: $url');
    try {
      final response = await http.get(url, headers: headers);
      debugPrint('Status Code Respon Absen Stats: ${response.statusCode}');
      debugPrint('Body Respon Absen Stats: ${response.body}');
      if (response.statusCode == 200) {
        return AbsenStatsResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.',
        );
      } else {
        Map<String, dynamic> errorResponse = {};
        try {
          if (response.body.isNotEmpty)
            errorResponse = json.decode(response.body);
        } catch (e) {
          /* ignore */
        }
        throw Exception(
          'Error: ${errorResponse['message'] ?? 'Gagal mengambil statistik absensi.'} (Status: ${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }

  // Metode untuk POST Check In (tetap sama)
  Future<AttendanceResponse> checkIn({
    required String status,
    String? alasanIzin,
    required String checkInAddress, // TAMBAHKAN PARAMETER INI
  }) async {
    final token = await _getToken();
    final position = await _getCurrentLocation();
    // final String checkAddress = "Jakarta"; // HAPUS BARIS INI

    final url = Uri.parse('${_baseUrl}api/absen/check-in');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> body = {
      'check_in_lat': position.latitude.toString(),
      'check_in_lng': position.longitude.toString(),
      'check_address': checkInAddress, // GUNAKAN PARAMETER checkInAddress
      'status': status,
    };

    if (status == 'izin') {
      if (alasanIzin == null || alasanIzin.isEmpty) {
        throw Exception('Alasan izin wajib diisi jika status adalah "izin".');
      }
      body['alasan_izin'] = alasanIzin;
    }

    debugPrint('Permintaan Check In URL: $url');
    debugPrint('Permintaan Check In Body: $body');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );
      debugPrint('Status Code Respon Check In: ${response.statusCode}');
      debugPrint('Body Respon Check In: ${response.body}');

      if (response.statusCode == 200) {
        return AttendanceResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 422) {
        Map<String, dynamic> errorResponse = json.decode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Data tidak valid.';
        if (errorResponse.containsKey('errors') &&
            errorResponse['errors'] is Map) {
          (errorResponse['errors'] as Map).forEach((key, value) {
            if (value is List)
              errorMessage += '\n${key.toUpperCase()}: ${value.join(', ')}';
          });
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.',
        );
      } else {
        String serverMessage = 'Terjadi kesalahan pada server saat Check In.';
        try {
          if (response.body.isNotEmpty)
            serverMessage =
                json.decode(response.body)['message'] ?? serverMessage;
        } catch (e) {
          /* ignore */
        }
        throw Exception('$serverMessage (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan tidak terduga saat Check In: ${e.toString()}',
      );
    }
  }

  // Metode untuk POST Check Out (tetap sama)
  Future<AttendanceResponse> checkOut({
    required String checkOutAddress, // TAMBAHKAN PARAMETER INI
  }) async {
    final token = await _getToken();
    final position = await _getCurrentLocation();
    // final String checkAddress = "Jakarta"; // HAPUS BARIS INI

    final url = Uri.parse('${_baseUrl}api/absen/check-out');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = {
      'check_out_lat': position.latitude.toString(),
      'check_out_lng': position.longitude.toString(),
      'check_out_address': checkOutAddress, // GUNAKAN PARAMETER checkOutAddress
    };

    debugPrint('Permintaan Check Out URL: $url');
    debugPrint('Permintaan Check Out Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: json.encode(body));
      debugPrint('Status Code Respon Check Out: ${response.statusCode}');
      debugPrint('Body Respon Check Out: ${response.body}');

      if (response.statusCode == 200) { return AttendanceResponse.fromJson(json.decode(response.body)); }
      else if (response.statusCode == 422) { Map<String, dynamic> errorResponse = json.decode(response.body); String errorMessage = errorResponse['message'] ?? 'Data tidak valid.'; if (errorResponse.containsKey('errors') && errorResponse['errors'] is Map) { (errorResponse['errors'] as Map).forEach((key, value) { if (value is List) errorMessage += '\n${key.toUpperCase()}: ${value.join(', ')}'; }); } throw Exception(errorMessage); }
      else if (response.statusCode == 401) { throw Exception('Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.'); }
      else if (response.statusCode == 400 && response.body.contains("Anda belum melakukan absen masuk hari ini")) { throw Exception('Anda belum melakukan absen masuk hari ini.'); }
      else if (response.statusCode == 400 && response.body.contains("Status izin tidak memerlukan absen keluar")) { throw Exception('Status izin tidak memerlukan absen keluar. (Anda dalam status izin)'); }
      else if (response.statusCode == 400 && response.body.contains("Anda sudah melakukan absen keluar hari ini")) { throw Exception('Anda sudah melakukan absen keluar hari ini. Tidak bisa Check Out lagi.'); }
      else { String serverMessage = 'Terjadi kesalahan pada server saat Check Out.'; try { if (response.body.isNotEmpty) serverMessage = json.decode(response.body)['message'] ?? serverMessage; } catch (e) { /* ignore */ } throw Exception('$serverMessage (Status: ${response.statusCode})'); }
    } on SocketException { throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'); } catch (e) { throw Exception('Terjadi kesalahan tidak terduga: ${e.toString()}'); }
  }
  /// Mengambil riwayat absensi berdasarkan rentang tanggal.
  /// Endpoint: GET /api/absen/history
  Future<List<AttendanceRecord>> getAttendanceHistory(
    String startDate,
    String endDate,
  ) async {
    final token = await _getToken();
    final url = Uri.parse(
      '${_baseUrl}api/absen/history?start=$startDate&end=$endDate',
    );
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('Permintaan Riwayat Absensi URL: $url');
    debugPrint('Permintaan Riwayat Absensi Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);
      debugPrint('Status Code Respon Riwayat Absensi: ${response.statusCode}');
      debugPrint('Body Respon Riwayat Absensi: ${response.body}');

      if (response.statusCode == 200) {
        final ListAttendanceHistoryResponse historyResponse =
            ListAttendanceHistoryResponse.fromJson(json.decode(response.body));
        return historyResponse.data;
      }
      // Penanganan No data: API mengembalikan 200 OK dengan data: []
      else if (response.statusCode == 200 &&
          response.body.contains('"data":[]')) {
        return []; // Mengembalikan list kosong jika tidak ada data
      }
      // Penanganan "Params kurang" (jika endpoint membutuhkan keduanya)
      else if (response.statusCode == 400 &&
          response.body.contains(
            "Harap kirimkan kedua tanggal: start dan end.",
          )) {
        throw Exception(
          'Parameter tanggal (start dan end) wajib diisi untuk riwayat.',
        );
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.',
        );
      } else {
        Map<String, dynamic> errorResponse = {};
        try {
          if (response.body.isNotEmpty)
            errorResponse = json.decode(response.body);
        } catch (e) {
          /* ignore */
        }
        final String errorMessage =
            errorResponse['message'] ?? 'Gagal mengambil riwayat absensi.';
        throw Exception(
          'Error: $errorMessage (Status: ${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan tidak terduga saat mengambil riwayat absensi: ${e.toString()}',
      );
    }
  }

  /// Menghapus record absensi.
  /// Endpoint: DELETE /api/absen/{id}
  Future<AttendanceResponse> deleteAttendanceRecord(int id) async {
    final token = await _getToken();
    final url = Uri.parse(
      '${_baseUrl}api/absen/$id',
    ); // Endpoint DELETE dengan ID
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('Permintaan Hapus Absensi URL: $url');
    debugPrint('Permintaan Hapus Absensi Headers: $headers');

    try {
      final response = await http.delete(url, headers: headers);
      debugPrint('Status Code Respon Hapus Absensi: ${response.statusCode}');
      debugPrint('Body Respon Hapus Absensi: ${response.body}');

      if (response.statusCode == 200) {
        return AttendanceResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404 &&
          response.body.contains("Id not found")) {
        throw Exception('Record absensi tidak ditemukan.');
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.',
        );
      } else {
        Map<String, dynamic> errorResponse = {};
        try {
          if (response.body.isNotEmpty)
            errorResponse = json.decode(response.body);
        } catch (e) {
          /* ignore */
        }
        final String errorMessage =
            errorResponse['message'] ?? 'Gagal menghapus record absensi.';
        throw Exception(
          'Error: $errorMessage (Status: ${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan tidak terduga saat menghapus absensi: ${e.toString()}',
      );
    }
  }
}

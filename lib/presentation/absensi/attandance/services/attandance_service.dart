import 'package:absensi_maps/models/attandance_model.dart';
import 'package:absensi_maps/models/generic_api_service.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk mendapatkan token
import 'package:absensi_maps/api/api_service.dart'; // Import ApiService Anda yang sudah ada
// Import model respons generik jika Anda membuatnya di file terpisah


// Kelas pembungkus untuk respons API yang konsisten (sebelumnya sudah ada)
class AttendanceApiResponse {
  final String message;
  final Attendance? data; // Data absensi tunggal, bisa null jika tidak ada absensi hari ini

  AttendanceApiResponse({required this.message, this.data});

  factory AttendanceApiResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceApiResponse(
      // Perbaikan: Pastikan pesan default lebih informatif jika null
      message: json['message'] as String? ?? 'Respons sukses tanpa pesan.', 
      data: json['data'] == null
          ? null
          : Attendance.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

// Kelas pembungkus untuk respons History API (sebelumnya sudah ada)
class AttendanceHistoryResponse {
  final String message;
  final List<Attendance> data; // Daftar absensi

  AttendanceHistoryResponse({required this.message, required this.data});

  factory AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryResponse(
      // Perbaikan: Pastikan pesan default lebih informatif jika null
      message: json['message'] as String? ?? 'Daftar riwayat berhasil dimuat.', 
      data: (json['data'] as List<dynamic>?)
            ?.map((item) => Attendance.fromJson(item as Map<String, dynamic>))
            .toList() ??
          [], // Pastikan list tidak null
    );
  }
}

class AttendanceService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Helper untuk mendapatkan token dari secure storage
  Future<String> _getToken() async {
    final token = await _secureStorage.read(key: ApiService.tokenKey);
    if (token == null) {
      throw Exception('Token otentikasi tidak ditemukan. Harap login ulang.');
    }
    return token;
  }

  /// Mengambil status absensi hari ini.
  Future<AttendanceApiResponse> getTodayAttendance() async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> responseData = await ApiService.getTodayAttendance(token);
      debugPrint('AttendanceService: Response from ApiService.getTodayAttendance: $responseData');
      
      // Logika khusus untuk "belum absen"
      if (responseData['message'] != null && responseData['data'] == null && responseData['message'].contains('belum absen')) {
        return AttendanceApiResponse(message: responseData['message'], data: null);
      }

      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in getTodayAttendance service: $e');
      rethrow;
    }
  }

  /// Melakukan check-in.
  // Perbaikan: Hapus parameter `status` karena sudah hardcoded di ApiService
  Future<AttendanceApiResponse> checkIn({
    // required String status, // <-- DIHAPUS
    String? alasanIzin, // Jika ini hanya untuk status izin, pertimbangkan apakah tetap diperlukan di sini
    required double latitude,
    required double longitude,
    required String checkInAddress,
  }) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> responseData = await ApiService.checkIn(
        token: token,
        latitude: latitude,
        longitude: longitude,
        address: checkInAddress,
      );
      debugPrint('AttendanceService: Response from ApiService.checkIn: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in checkIn service: $e');
      rethrow;
    }
  }

  /// Melakukan check-out.
  Future<AttendanceApiResponse> checkOut({
    required double latitude,
    required double longitude,
    required String checkOutAddress,
  }) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> responseData = await ApiService.checkOut(
        token: token,
        latitude: latitude,
        longitude: longitude,
        address: checkOutAddress,
      );
      debugPrint('AttendanceService: Response from ApiService.checkOut: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in checkOut service: $e');
      rethrow;
    }
  }

  /// Mengirim absensi izin.
  Future<AttendanceApiResponse> submitIzin({
    required String date,
    required String reason,
  }) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> responseData = await ApiService.submitIzin(
        token: token,
        date: date,
        reason: reason,
      );
      debugPrint('AttendanceService: Response from ApiService.submitIzin: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in submitIzin service: $e');
      rethrow;
    }
  }

  /// Mendapatkan riwayat absensi berdasarkan rentang tanggal.
  Future<List<Attendance>> getAttendanceHistory(String startDate, String endDate) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> responseData = await ApiService.getHistory(token,
        startDate: startDate,
        endDate: endDate,
      );
      debugPrint('AttendanceService: Response from ApiService.getHistory: $responseData');
      return AttendanceHistoryResponse.fromJson(responseData).data;
    } catch (e) {
      debugPrint('AttendanceService: Error in getAttendanceHistory service: $e');
      rethrow;
    }
  }

  /// Menghapus record absensi.
  // Perbaikan: Mengembalikan GenericApiResponse untuk konsistensi tipe
  Future<GenericApiResponse> deleteAttendanceRecord(int recordId) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> responseData = await ApiService.deleteAttendance(
        token: token,
        id: recordId,
      );
      debugPrint('AttendanceService: Response from ApiService.deleteAttendance: $responseData');
      // Perbaikan: Mengembalikan model GenericApiResponse
      return GenericApiResponse.fromJson(responseData); 
    } catch (e) {
      debugPrint('AttendanceService: Error in deleteAttendanceRecord service: $e');
      rethrow;
    }
  }
}
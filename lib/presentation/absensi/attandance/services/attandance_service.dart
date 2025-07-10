// lib/presentation/absensi/attandance/services/attandance_service.dart

import 'package:absensi_maps/models/attandance_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:absensi_maps/api/api_service.dart';
// Kelas pembungkus untuk respons API yang konsisten (dari pembahasan sebelumnya)
class AttendanceApiResponse {
  final String message;
  final Attendance? data; // Data absensi tunggal, bisa null jika tidak ada absensi hari ini

  AttendanceApiResponse({required this.message, this.data});

  factory AttendanceApiResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceApiResponse(
      message: json['message'] as String? ?? 'Pesan tidak diketahui',
      data: json['data'] == null
          ? null
          : Attendance.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

// Kelas pembungkus untuk respons History API (baru)
class AttendanceHistoryResponse {
  final String message;
  final List<Attendance> data; // Daftar absensi

  AttendanceHistoryResponse({required this.message, required this.data});

  factory AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryResponse(
      message: json['message'] as String? ?? 'Pesan tidak diketahui',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Attendance.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [], // Pastikan list tidak null
    );
  }
}


class AttendanceService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String> _getToken() async {
    final token = await _secureStorage.read(key: ApiService.tokenKey);
    if (token == null) {
      throw Exception('Token otentikasi tidak ditemukan. Harap login ulang.');
    }
    return token;
  }

  Future<AttendanceApiResponse> getTodayAttendance() async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> responseData = await ApiService.getTodayAttendance(token);
      debugPrint('Response from ApiService.getTodayAttendance: $responseData');

      if (responseData['message'] != null && responseData['data'] == null && responseData['message'].contains('belum absen')) {
        return AttendanceApiResponse(message: responseData['message'], data: null);
      }

      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('Error in getTodayAttendance service: $e');
      rethrow;
    }
  }

  Future<AttendanceApiResponse> checkIn({
    required String status,
    String? alasanIzin,
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
      debugPrint('Response from ApiService.checkIn: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('Error in checkIn service: $e');
      rethrow;
    }
  }

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
      debugPrint('Response from ApiService.checkOut: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('Error in checkOut service: $e');
      rethrow;
    }
  }

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
      debugPrint('Response from ApiService.submitIzin: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('Error in submitIzin service: $e');
      rethrow;
    }
  }

  // ***** BARU: Mendapatkan riwayat absensi berdasarkan rentang tanggal *****
  Future<List<Attendance>> getAttendanceHistory(String startDate, String endDate) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> responseData = await ApiService.getHistory(token,
        startDate: startDate,
        endDate: endDate,
      );
      debugPrint('Response from ApiService.getHistory: $responseData');
      // Menggunakan AttendanceHistoryResponse untuk parsing list
      return AttendanceHistoryResponse.fromJson(responseData).data;
    } catch (e) {
      debugPrint('Error in getAttendanceHistory service: $e');
      rethrow;
    }
  }

  // ***** BARU: Menghapus record absensi *****
  Future<Map<String, dynamic>> deleteAttendanceRecord(int recordId) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> responseData = await ApiService.deleteAttendance(
        token: token,
        id: recordId,
      );
      debugPrint('Response from ApiService.deleteAttendance: $responseData');
      return responseData; // Mengembalikan Map langsung seperti ApiService
    } catch (e) {
      debugPrint('Error in deleteAttendanceRecord service: $e');
      rethrow;
    }
  }
}
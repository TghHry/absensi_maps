// lib/presentation/absensi/attandance/services/attandance_service.dart

import 'package:absensi_maps/models/session_manager.dart'; // Pastikan path ini benar
// Hapus import yang salah ini:
// import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_api_service.dart';
// Ganti dengan import model AttendanceApiResponse yang benar:
// import 'package:absensi_maps/models/attendance_api_response.dart'; // <<< PERBAIKAN: IMPORT INI
import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_api_service.dart';

import 'package:flutter/foundation.dart';
import 'package:absensi_maps/api/api_service.dart';
import 'package:absensi_maps/models/attandance_model.dart';


class AttendanceService {
  final SessionManager _sessionManager = SessionManager();

  /// Mengambil status absensi hari ini dari API.
  Future<AttendanceApiResponse> getTodayAttendance() async {
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
      }
      // ApiService.getTodayAttendance sekarang mengembalikan Map<String, dynamic>
      // yang sudah menangani kasus 404 sebagai data: null
      final Map<String, dynamic> responseData = await ApiService.getTodayAttendance(token);
      debugPrint('AttendanceService: Raw response from ApiService.getTodayAttendance: $responseData');

      // Langsung parsing ke AttendanceApiResponse
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in getTodayAttendance service: $e');
      rethrow; // Lempar kembali error ke lapisan UI
    }
  }

  /// Melakukan check-in.
  Future<AttendanceApiResponse> checkIn({
    required double latitude,
    required double longitude,
    required String checkInAddress,
    String? alasanIzin, // Jika catatan digunakan sebagai alasan izin
  }) async {
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
      }
      // ApiService.checkIn sekarang membutuhkan parameter status
      final Map<String, dynamic> responseData = await ApiService.checkIn(
        token: token,
        latitude: latitude,
        longitude: longitude,
        address: checkInAddress,
        status: 'masuk', // Status default untuk check-in
      );
      debugPrint('AttendanceService: Raw response from ApiService.checkIn: $responseData');
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
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
      }
      final Map<String, dynamic> responseData = await ApiService.checkOut(
        token: token,
        latitude: latitude,
        longitude: longitude,
        address: checkOutAddress,
      );
      debugPrint('AttendanceService: Raw response from ApiService.checkOut: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in checkOut service: $e');
      rethrow;
    }
  }

  /// Mengajukan izin.
  Future<AttendanceApiResponse> submitIzin({
    required String date,
    required String reason,
  }) async {
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
      }
      final Map<String, dynamic> responseData = await ApiService.submitIzin(
        token: token,
        date: date,
        reason: reason,
      );
      debugPrint('AttendanceService: Raw response from ApiService.submitIzin: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in submitIzin service: $e');
      rethrow;
    }
  }

  /// Mengambil riwayat absensi.
  Future<List<Attendance>> getAttendanceHistory(
      String startDate, String endDate) async {
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
      }
      final Map<String, dynamic> responseData =
          await ApiService.getHistory(token, startDate: startDate, endDate: endDate);
      debugPrint('AttendanceService: Raw response from ApiService.getHistory: $responseData');

      // Asumsi API mengembalikan List<Map<String, dynamic>> di bawah key 'data'
      final List<dynamic> historyListJson = responseData['data'] as List<dynamic>? ?? [];
      return historyListJson.map((json) => Attendance.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('AttendanceService: Error in getAttendanceHistory service: $e');
      rethrow;
    }
  }

  /// Menghapus record absensi.
  // Tetap mengembalikan AttendanceApiResponse sesuai permintaan Anda
  Future<AttendanceApiResponse> deleteAttendanceRecord(int recordId) async {
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
      }
      final Map<String, dynamic> responseData = await ApiService.deleteAttendance(
        token: token,
        id: recordId,
      );
      debugPrint('AttendanceService: Raw response from ApiService.deleteAttendance: $responseData');
      return AttendanceApiResponse.fromJson(responseData); // Mengembalikan AttendanceApiResponse
    } catch (e) {
      debugPrint('AttendanceService: Error in deleteAttendanceRecord service: $e');
      rethrow;
    }
  }
}
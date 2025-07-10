// lib/presentation/absensi/profile/services/profile_service.dart

import 'package:flutter/foundation.dart';
import 'package:absensi_maps/api/api_service.dart'; // Import ApiService
// import 'package:absensi_maps/models/user_model.dart'; // User model tidak diperlukan langsung di sini
import 'package:absensi_maps/models/profile_model.dart'; // Import ProfileResponse dan ProfileUser

class ProfileService {
  /// Mengambil data profil user terbaru.
  Future<ProfileResponse> fetchUserProfile(String token) async {
    try {
      final Map<String, dynamic> responseData = await ApiService.getProfile(
        token,
      );
      debugPrint('Raw response from ApiService.getProfile: $responseData');
      return ProfileResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('Error in fetchUserProfile service: $e');
      rethrow;
    }
  }

  /// Memperbarui foto profil.
  Future<Map<String, dynamic>> updateProfilePhoto(
    String token,
    String base64Photo,
  ) async {
    try {
      final Map<String, dynamic> responseData =
          await ApiService.updateProfilePhoto(
            token: token,
            base64Photo: base64Photo,
          );
      debugPrint(
        'Raw response from ApiService.updateProfilePhoto: $responseData',
      );
      return responseData;
    } catch (e) {
      debugPrint('Error in updateProfilePhoto service: $e');
      rethrow;
    }
  }

  /// Memperbarui data profil lainnya (nama, jenis kelamin, dll.)
  Future<ProfileResponse> updateProfileData(
    String token, { // Pastikan named parameters
    required String name,
    String? jenisKelamin,
    int? trainingId,
    int? batchId,
  }) async {
    try {
      // ***** SOLUSI: CUKUP PANGGIL METODE DARI ApiService DENGAN ARGUMEN YANG BENAR *****
      final Map<String, dynamic> responseData =
          await ApiService.updateProfileData(
            token: token,
            name: name,
            jenisKelamin: jenisKelamin,
            trainingId: trainingId,
            batchId: batchId,
          );
      debugPrint(
        'Raw response from ApiService.updateProfileData: $responseData',
      );
      // Mengonversi respons Map<String, dynamic> menjadi ProfileResponse
      return ProfileResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('Error in updateProfileData service: $e');
      rethrow;
    }
  }
}

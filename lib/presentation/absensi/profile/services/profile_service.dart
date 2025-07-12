// lib/presentation/absensi/profile/services/profile_service.dart

import 'package:flutter/foundation.dart';
import 'package:absensi_maps/api/api_service.dart';
import 'package:absensi_maps/models/profile_model.dart';
// Jika Anda membuat model GenericApiResponse, Anda mungkin ingin mengimpornya juga
// import 'package:absensi_maps/models/generic_api_response.dart'; 


class ProfileService {
  /// Mengambil data profil user terbaru.
  Future<ProfileResponse> fetchUserProfile(String token) async {
    try {
      final Map<String, dynamic> responseData = await ApiService.getProfile(token);
      debugPrint('ProfileService: Raw response from ApiService.getProfile: $responseData');
      return ProfileResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('ProfileService: Error in fetchUserProfile service: $e');
      rethrow;
    }
  }

  /// Memperbarui foto profil.
  // Ini masih mengembalikan Map<String, dynamic>. Jika API ini juga konsisten
  // mengembalikan pesan sukses, Anda bisa mengubahnya ke GenericApiResponse.
  Future<Map<String, dynamic>> updateProfilePhoto( // Pertimbangkan mengganti ini dengan GenericApiResponse jika responnya sederhana
    String token,
    String base64Photo,
  ) async {
    try {
      final Map<String, dynamic> responseData =
          await ApiService.updateProfilePhoto(
              token: token, base64Photo: base64Photo);
      debugPrint('ProfileService: Raw response from ApiService.updateProfilePhoto: $responseData');
      return responseData;
    } catch (e) {
      debugPrint('ProfileService: Error in updateProfilePhoto service: $e');
      rethrow;
    }
  }

  /// Memperbarui data profil lainnya (sekarang diasumsikan hanya nama)
  // PERUBAHAN: Signature metode disesuaikan agar hanya menerima 'name'
  // sesuai dengan perubahan yang kita lakukan/akan lakukan di ApiService.
  Future<ProfileResponse> updateProfileData(
    String token, {
    required String name,
    // Hapus parameter jenisKelamin, trainingId, batchId dari sini,
    // karena ApiService.updateProfileData juga sudah kita set hanya menerima 'name'.
  }) async {
    try {
      final Map<String, dynamic> responseData =
          await ApiService.updateProfileData(
            token: token,
            name: name,
            // Hapus argumen ini dari panggilan ke ApiService.updateProfileData
            // jenisKelamin: jenisKelamin,
            // trainingId: trainingId,
            // batchId: batchId,
          );
      debugPrint('ProfileService: Raw response from ApiService.updateProfileData: $responseData');
      return ProfileResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('ProfileService: Error in updateProfileData service: $e');
      rethrow;
    }
  }
}
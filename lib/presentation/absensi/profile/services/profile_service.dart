// lib/presentation/absensi/profile/services/profile_service.dart

import 'package:flutter/foundation.dart';
import 'package:absensi_maps/api/api_service.dart';
import 'package:absensi_maps/models/profile_model.dart';

class ProfileService {
  Future<ProfileResponse> fetchUserProfile(String token) async {
    try {
      final Map<String, dynamic> responseData = await ApiService.getProfile(token);
      debugPrint('Raw response from ApiService.getProfile: $responseData');
      return ProfileResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('Error in fetchUserProfile service: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfilePhoto(
    String token,
    String base64Photo,
  ) async {
    try {
      final Map<String, dynamic> responseData =
          await ApiService.updateProfilePhoto(
              token: token, base64Photo: base64Photo);
      debugPrint('Raw response from ApiService.updateProfilePhoto: $responseData');
      return responseData;
    } catch (e) {
      debugPrint('Error in updateProfilePhoto service: $e');
      rethrow;
    }
  }

  // Memperbarui data profil lainnya (sekarang hanya nama)
  // Ubah parameter agar hanya menerima 'name'
  Future<ProfileResponse> updateProfileData(
    String token, {
    required String name,
    // Hapus parameter jenisKelamin, trainingId, batchId dari sini
  }) async {
    try {
      final Map<String, dynamic> responseData =
          await ApiService.updateProfileData(
              token: token, name: name); // Hanya panggil dengan 'name'
      debugPrint('Raw response from ApiService.updateProfileData: $responseData');
      return ProfileResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('Error in updateProfileData service: $e');
      rethrow;
    }
  }
}
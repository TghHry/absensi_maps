// lib/services/session_manager.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_maps/models/user_model.dart'; // Import User model yang baru Anda buat
import 'package:absensi_maps/api/api_service.dart'; // Untuk akses ApiService.tokenKey

class SessionManager {
  // Kunci untuk menyimpan data pengguna di SharedPreferences
  static const String _userKey = 'current_user_profile_json'; // Nama kunci yang lebih deskriptif
  // Menggunakan ApiService.tokenKey untuk konsistensi dengan ApiService
  // static const String _tokenKey = ApiService.tokenKey; // Ini tidak perlu dideklarasikan ulang jika sudah di ApiService

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Menyimpan objek User lengkap sebagai string JSON di SharedPreferences
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    // Token akan disimpan secara terpisah oleh ApiService atau saat login
    print('SessionManager: User data saved to SharedPreferences.');
  }

  // Mengambil objek User dari SharedPreferences
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = prefs.getString(_userKey);
    if (userJsonString != null && userJsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJsonString) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        print('SessionManager: Error decoding user data from SharedPreferences: $e');
        return null;
      }
    }
    return null;
  }

  // Mengambil token dari FlutterSecureStorage (meneruskan ke ApiService)
  Future<String?> getToken() async {
    return await ApiService.getToken(); // Memanggil getToken dari ApiService
  }

  // Menyimpan token ke FlutterSecureStorage (meneruskan ke ApiService)
  Future<void> saveToken(String token) async {
    await ApiService.saveToken(token); // Memanggil saveToken dari ApiService
  }

  // Membersihkan semua data sesi (User dan Token)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey); // Hapus data user dari SharedPreferences
    await ApiService.deleteToken(); // Hapus token dari SecureStorage melalui ApiService
    print('SessionManager: Session cleared.');
  }
}
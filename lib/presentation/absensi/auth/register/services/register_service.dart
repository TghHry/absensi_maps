// // File: lib/services/register_service.dart
// // (Pastikan sudah seperti ini, atau sesuaikan jika ada perbedaan)

// import 'dart:convert';
// import 'dart:io';
// import 'package:absensi_maps/presentation/absensi/auth/register/models/register_model.dart'; // Sesuaikan lokasi model Anda
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';

// class RegisterService {
//   final String _baseUrl = 'https://appabsensi.mobileprojp.com/';

//   Future<RegistrationResponse> registerUser(
//     String name,
//     String email,
//     String password,
//     String batchId,
//     String trainingId,
//     String jenisKelamin, // 'L' atau 'P'
//   ) async {
//     final url = Uri.parse('${_baseUrl}api/register');
    
//     final headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
    
//     final body = json.encode({
//       'name': name,
//       'email': email,
//       'password': password,
//       'password_confirmation': password,
//       'batch_id': batchId, // Pastikan nama key sesuai API
//       'training_id': trainingId, // Pastikan nama key sesuai API
//       'jenis_kelamin': jenisKelamin, // Pastikan nama key sesuai API
//     });

//     debugPrint('Permintaan Registrasi URL: $url');
//     debugPrint('Permintaan Registrasi Headers: $headers');
//     debugPrint('Permintaan Registrasi Body: $body');

//     try {
//       final response = await http.post(url, headers: headers, body: body);

//       debugPrint('Status Code Respon Registrasi: ${response.statusCode}');
//       debugPrint('Body Respon Registrasi: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         return RegistrationResponse.fromJson(jsonResponse);
//       } else if (response.statusCode == 422) {
//         Map<String, dynamic> errorResponse = {};
//         String serverMessage = 'Data yang Anda masukkan tidak valid.';
//         try {
//           if (response.body.isNotEmpty && !response.body.trim().startsWith('<!DOCTYPE html>')) {
//             errorResponse = json.decode(response.body);
//             serverMessage = errorResponse['message'] ?? serverMessage;
            
//             if (errorResponse.containsKey('errors') && errorResponse['errors'] is Map) {
//                 (errorResponse['errors'] as Map).forEach((key, value) {
//                     if (value is List) {
//                       serverMessage += '\n${key.toUpperCase()}: ${value.join(', ')}';
//                     }
//                 });
//             }
//           } else {
//              serverMessage = 'Server mengembalikan status ${response.statusCode}. '
//                              'Kemungkinan URL atau konfigurasi API salah. '
//                              'Body Respons: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...';
//           }
//         } catch (decodeError) {
//           debugPrint('Gagal mendekode error response body (non-JSON): $decodeError');
//           serverMessage = 'Registrasi gagal: Respons server tidak dapat dipahami. Status: ${response.statusCode}';
//         }
//         throw Exception(serverMessage);
//       } else if (response.statusCode == 401) {
//         throw Exception('Sesi Anda telah berakhir atau token tidak valid. Mohon login kembali.');
//       } else {
//         String serverMessage = 'Terjadi kesalahan pada server. Mohon coba lagi.';
//         try {
//             if (response.body.isNotEmpty) {
//                 Map<String, dynamic> errorJson = json.decode(response.body);
//                 serverMessage = errorJson['message'] ?? serverMessage;
//             }
//         } catch (e) {
//             // Body mungkin bukan JSON, gunakan pesan default
//         }
//         throw Exception('$serverMessage (Status: ${response.statusCode})');
//       }
//     } on SocketException catch (e) {
//         debugPrint('SocketException during registration: $e');
//         throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda atau coba lagi nanti.');
//     } catch (e) {
//         debugPrint('General error during registration: $e');
//         throw Exception('Terjadi kesalahan tidak terduga saat registrasi. Detail: ${e.toString()}');
//     }
//   }
// }
// lib/models/attendance_api_response.dart

import 'dart:convert';
import 'package:absensi_maps/models/attandance_model.dart'; // Pastikan path ini benar

// Helper untuk parse dari JSON string
AttendanceApiResponse attendanceApiResponseFromJson(String str) =>
    AttendanceApiResponse.fromJson(json.decode(str));

// Helper untuk konversi ke JSON string (opsional, mungkin tidak sering dipakai)
String attendanceApiResponseToJson(AttendanceApiResponse data) => json.encode(data.toJson());

class AttendanceApiResponse {
  final String message;
  final Attendance? data; // Properti 'data' bisa null jika tidak ada record absensi

  AttendanceApiResponse({
    required this.message,
    this.data, // Default null
  });

  factory AttendanceApiResponse.fromJson(Map<String, dynamic> json) => AttendanceApiResponse(
        message: json["message"] as String? ?? 'Pesan tidak diketahui',
        // Penting: Periksa apakah 'data' itu ada dan merupakan Map sebelum mencoba mem-parsingnya.
        // Jika data dari API adalah 'null' atau bukan Map (misal string kosong), anggap null.
        data: json["data"] == null || json["data"] is! Map
            ? null
            : Attendance.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(), // Akan menjadi null jika data objeknya null
      };
}
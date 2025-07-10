// lib/models/attendance_model.dart

// import 'dart:convert';
import 'package:intl/intl.dart'; // Tetap dibutuhkan untuk format tanggal
// import 'package:flutter/foundation.dart'; // Untuk debugPrint

class Attendance {
  final int id;
  final int userId;
  final DateTime date; // Ini adalah untuk tanggal utuh (misal dari attendance_date)
  final String? checkIn; // Ini akan langsung menyimpan string "HH:mm" dari API
  final String? checkOut; // Ini akan langsung menyimpan string "HH:mm" dari API

  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

  final String? checkInAddress;
  final String? checkOutAddress;
  final String status;
  final String? reason;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.checkInAddress,
    this.checkOutAddress,
    required this.status,
    this.reason,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    // ***** Hapus fungsi formatTime yang lama karena tidak lagi diperlukan untuk checkIn/checkOut *****
    // String? formatTime(String? dateTimeString) {
    //   if (dateTimeString == null) return null;
    //   try {
    //     return DateFormat('HH:mm').format(DateTime.parse(dateTimeString));
    //   } catch (e) {
    //     debugPrint('Error formatting time: $e');
    //     return '--:--';
    //   }
    // }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    return Attendance(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      // Date harus di-parse dari 'attendance_date' di JSON untuk mendapatkan objek DateTime tanggal absensi.
      date: DateTime.parse(json['attendance_date'] as String), // <--- GUNAKAN 'attendance_date' UNTUK PARSING TANGGAL UTUH
      
      // ***** SOLUSI: LANGSUNG AMBIL STRING WAKTU DARI JSON *****
      checkIn: json["check_in_time"] as String?,  // <--- UBAH DI SINI (gunakan check_in_time)
      checkOut: json["check_out_time"] as String?, // <--- UBAH DI SINI (gunakan check_out_time)
      
      status: json["status"] as String? ?? 'Tidak Diketahui',
      reason: json["alasan_izin"] as String?,

      checkInLat: parseDouble(json["check_in_lat"]),
      checkInLng: parseDouble(json["check_in_lng"]),
      checkOutLat: parseDouble(json["check_out_lat"]),
      checkOutLng: parseDouble(json["check_out_lng"]),

      checkInAddress: json["check_in_address"] as String?,
      checkOutAddress: json["check_out_address"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "date": DateFormat('yyyy-MM-dd').format(date), // Format tanggal untuk JSON jika diperlukan
        "check_in": checkIn, // Kirim string waktu apa adanya
        "check_out": checkOut, // Kirim string waktu apa adanya
        "check_in_lat": checkInLat,
        "check_in_lng": checkInLng,
        "check_out_lat": checkOutLat,
        "check_out_lng": checkOutLng,
        "check_in_address": checkInAddress,
        "check_out_address": checkOutAddress,
        "status": status,
        "alasan_izin": reason,
      };
}
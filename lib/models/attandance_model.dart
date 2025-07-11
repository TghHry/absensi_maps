// lib/models/attendance_model.dart

import 'package:intl/intl.dart';

class Attendance {
  final int id;
  final int userId;
  final DateTime
  date; // Ini adalah untuk tanggal utuh (misal dari attendance_date)
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
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    return Attendance(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,

      // SOLUSI UNTUK "JAM MASUKNYA TIDAK ADA": Ambil string waktu secara langsung
      // Untuk properti 'date', gunakan 'attendance_date' dari JSON
      date: DateTime.parse(json['attendance_date'] as String),

      // 'checkIn' dan 'checkOut' akan langsung mengambil string "HH:mm" dari JSON
      checkIn:
          json["check_in_time"]
              as String?, // <--- PASTIKAN MENGGUNAKAN "check_in_time" (SESUAI API)
      checkOut:
          json["check_out_time"]
              as String?, // <--- PASTIKAN MENGGUNAKAN "check_out_time" (SESUAI API)

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
    "date": DateFormat(
      'yyyy-MM-dd',
    ).format(date), // Format tanggal untuk JSON jika diperlukan
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

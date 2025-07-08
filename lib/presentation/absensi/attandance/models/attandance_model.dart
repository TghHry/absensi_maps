// File: lib/models/attendance_models.dart

import 'dart:convert';

// Helper function untuk parsing DateTime yang fleksibel
DateTime? _tryParseDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }
  try {
    // Coba parse sebagai ISO 8601 (format standar)
    return DateTime.parse(dateString);
  } catch (e) {
    // Jika gagal, coba format YYYY-MM-DD HH:MM:SS (tanpa T dan Z)
    try {
      // Perlu memisahkan tanggal dan waktu jika ada, atau tambahkan 'T' di tengah
      // Ini adalah estimasi, jika formatnya selalu seperti itu (YYYY-MM-DD HH:MM:SS)
      if (dateString.length == 19 && dateString.contains(' ')) {
        return DateTime.parse(dateString.replaceFirst(' ', 'T') + 'Z'); // Asumsi UTC jika ada Z
      }
    } catch (e2) {
      // Biarkan null jika kedua format gagal
      debugPrint('Warning: Could not parse date string "$dateString": $e2');
    }
  }
  return null;
}

// Model untuk satu record absensi
class AttendanceRecord {
  final int? id; // Nullable karena mungkin belum ada ID saat check-in awal
  final int? userId;
  final DateTime? checkInTime; // check_in
  final String? checkInLocation; // check_in_location
  final String? checkInAddress; // check_address
  final DateTime? checkOutTime; // check_out
  final String? checkOutLocation; // check_out_location
  final String? checkOutAddress; // check_out_address
  final String? status; // "masuk" atau "izin"
  final String? alasanIzin; // alasan_izin, nullable
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? checkInLat; // check_in_lat (jika terpisah)
  final double? checkInLng; // check_in_lng (jika terpisah)
  final double? checkOutLat; // check_out_lat (jika terpisah)
  final double? checkOutLng; // check_out_lng (jika terpisah)

  AttendanceRecord({
    this.id,
    this.userId,
    this.checkInTime,
    this.checkInLocation,
    this.checkInAddress,
    this.checkOutTime,
    this.checkOutLocation,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    // Menangani check_in_location dan check_out_location sebagai string gabungan
    // Jika API mengirim lat/lng terpisah, gunakan itu. Jika tidak, coba parse dari string gabungan.
    double? parseLat(dynamic loc) {
      if (loc is double) return loc;
      if (loc is String) {
        final parts = loc.split(',');
        if (parts.length == 2) return double.tryParse(parts[0].trim());
      }
      return null;
    }

    double? parseLng(dynamic loc) {
      if (loc is double) return loc;
      if (loc is String) {
        final parts = loc.split(',');
        if (parts.length == 2) return double.tryParse(parts[1].trim());
      }
      return null;
    }

    // Ambil lat/lng dari field terpisah jika ada
    final cILat = json['check_in_lat'] is String ? double.tryParse(json['check_in_lat']) : json['check_in_lat'] as double?;
    final cILng = json['check_in_lng'] is String ? double.tryParse(json['check_in_lng']) : json['check_in_lng'] as double?;
    final cOLat = json['check_out_lat'] is String ? double.tryParse(json['check_out_lat']) : json['check_out_lat'] as double?;
    final cOLng = json['check_out_lng'] is String ? double.tryParse(json['check_out_lng']) : json['check_out_lng'] as double?;


    return AttendanceRecord(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      checkInTime: _tryParseDateTime(json['check_in'] as String?),
      checkInLocation: json['check_in_location'] as String?,
      checkInAddress: json['check_address'] as String?,
      checkOutTime: _tryParseDateTime(json['check_out'] as String?),
      checkOutLocation: json['check_out_location'] as String?,
      checkOutAddress: json['check_out_address'] as String?,
      status: json['status'] as String?,
      alasanIzin: json['alasan_izin'] as String?,
      createdAt: _tryParseDateTime(json['created_at'] as String?),
      updatedAt: _tryParseDateTime(json['updated_at'] as String?),
      checkInLat: cILat ?? parseLat(json['check_in_location']), // Prioritaskan field terpisah
      checkInLng: cILng ?? parseLng(json['check_in_location']),
      checkOutLat: cOLat ?? parseLat(json['check_out_location']),
      checkOutLng: cOLng ?? parseLng(json['check_out_location']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'check_in': checkInTime?.toIso8601String(),
      'check_in_location': checkInLocation,
      'check_address': checkInAddress,
      'check_out': checkOutTime?.toIso8601String(),
      'check_out_location': checkOutLocation,
      'check_out_address': checkOutAddress,
      'status': status,
      'alasan_izin': alasanIzin,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'check_in_lat': checkInLat,
      'check_in_lng': checkInLng,
      'check_out_lat': checkOutLat,
      'check_out_lng': checkOutLng,
    };
  }
}

// Model respons umum untuk Check-in dan Check-out
class AttendanceResponse {
  final String message;
  final AttendanceRecord? data; // Data bisa null untuk beberapa error

  AttendanceResponse({
    required this.message,
    this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      message: json['message'] as String,
      data: json['data'] != null ? AttendanceRecord.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}
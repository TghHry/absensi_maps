// File: lib/models/attendance_models.dart
// Pastikan sudah sesuai dengan ini, termasuk import flutter/foundation.dart jika menggunakan debugPrint di helper.

import 'dart:convert';
import 'package:flutter/foundation.dart'; // Untuk debugPrint di _tryParseDateTime

// Helper function untuk parsing DateTime yang fleksibel (seperti sebelumnya)
DateTime? _tryParseDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    try {
      if (dateString.length == 19 && dateString.contains(' ')) {
        return DateTime.parse(dateString.replaceFirst(' ', 'T') + 'Z');
      }
    } catch (e2) {
      debugPrint('Warning: Could not parse date string "$dateString": $e2');
    }
  }
  return null;
}

// Model untuk satu record absensi (tetap sama)
class AttendanceRecord {
  final int? id;
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
    // Logika parsing lat/lng dari string gabungan atau field terpisah
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
      checkInLat: cILat ?? parseLat(json['check_in_location']),
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

// Model respons umum untuk Check-in dan Check-out (tetap sama)
class AttendanceResponse {
  final String message;
  final AttendanceRecord? data;

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

// MODEL BARU UNTUK LIST RIWAYAT ABSENSI
class ListAttendanceHistoryResponse {
  final String message;
  final List<AttendanceRecord> data;

  ListAttendanceHistoryResponse({
    required this.message,
    required this.data,
  });

  factory ListAttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ListAttendanceHistoryResponse(
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((record) => record.toJson()).toList(),
    };
  }
}

// Model untuk Absen Stats (tetap sama)
class AbsenStats {
  final int totalAbsen;
  final int totalMasuk;
  final int totalIzin;
  final bool sudahAbsenHariIni;

  AbsenStats({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
  });

  factory AbsenStats.fromJson(Map<String, dynamic> json) {
    return AbsenStats(
      totalAbsen: json['total_absen'] as int,
      totalMasuk: json['total_masuk'] as int,
      totalIzin: json['total_izin'] as int,
      sudahAbsenHariIni: json['sudah_absen_hari_ini'] as bool,
    );
  }
}

// Model respons untuk Absen Stats (tetap sama)
class AbsenStatsResponse {
  final String message;
  final AbsenStats data;

  AbsenStatsResponse({
    required this.message,
    required this.data,
  });

  factory AbsenStatsResponse.fromJson(Map<String, dynamic> json) {
    return AbsenStatsResponse(
      message: json['message'] as String,
      data: AbsenStats.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
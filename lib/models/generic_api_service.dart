// lib/models/generic_api_response.dart

import 'dart:convert';

// Helper untuk parse dari JSON string
GenericApiResponse genericApiResponseFromJson(String str) => GenericApiResponse.fromJson(json.decode(str));

// Helper untuk konversi ke JSON string
String genericApiResponseToJson(GenericApiResponse data) => json.encode(data.toJson());

class GenericApiResponse {
  final String message;

  GenericApiResponse({required this.message});

  factory GenericApiResponse.fromJson(Map<String, dynamic> json) => GenericApiResponse(
    message: json["message"] as String? ?? 'Pesan tidak diketahui', // Default message if null
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}
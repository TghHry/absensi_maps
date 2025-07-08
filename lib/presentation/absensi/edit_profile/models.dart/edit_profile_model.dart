
import 'dart:convert';
import 'package:absensi_maps/presentation/absensi/auth/login/models/login_model.dart';

// MODEL BARU UNTUK EDIT PROFILE
class EditProfileResponse {
  final String message;
  final User data; // Objek 'data' langsung berisi User

  EditProfileResponse({
    required this.message,
    required this.data,
  });

  factory EditProfileResponse.fromJson(Map<String, dynamic> json) {
    return EditProfileResponse(
      message: json['message'] as String,
      data: User.fromJson(json['data'] as Map<String, dynamic>), // Langsung parse 'data' sebagai User
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

// --- Contoh penggunaan model baru (opsional, hanya untuk pengujian) ---
void main() {
  final String successJsonString = """
  {
      "message": "Profil berhasil diperbarui",
      "data": {
          "id": 1,
          "name": "budianduks",
          "email": "budi@example.com",
          "email_verified_at": null,
          "created_at": "2025-04-10T07:01:59.000000Z",
          "updated_at": "2025-04-11T01:45:42.000000Z"
      }
  }
  """;

  final String errorJsonString = """
  {
      "message": "Nama wajib diisi.",
      "errors": {
          "name": [
              "Nama wajib diisi."
          ]
      }
  }
  """;

  // Contoh Deserialisasi Sukses
  final Map<String, dynamic> successJsonMap = json.decode(successJsonString);
  final EditProfileResponse successResponse = EditProfileResponse.fromJson(successJsonMap);
  print('Pesan Sukses: ${successResponse.message}');
  print('Nama User Setelah Edit: ${successResponse.data.name}');

  // Contoh Penanganan Error (ini akan ditangani di service, bukan oleh model EditProfileResponse)
  final Map<String, dynamic> errorJsonMap = json.decode(errorJsonString);
  print('Pesan Error: ${errorJsonMap['message']}');
  if (errorJsonMap.containsKey('errors')) {
    print('Detail Error Nama: ${errorJsonMap['errors']['name'][0]}');
  }
}
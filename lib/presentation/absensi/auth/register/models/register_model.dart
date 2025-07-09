
import 'dart:convert';

import 'package:absensi_maps/presentation/absensi/profile/models/user_base.dart';


// Model untuk objek 'data' dari API response
class RegistrationData {
  final String token;
  final User user; // Menggunakan User

  RegistrationData({
    required this.token,
    required this.user,
  });

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

// Model untuk keseluruhan response API
class RegistrationResponse {
  final String message;
  final RegistrationData data; // Menggunakan RegistrationData

  RegistrationResponse({
    required this.message,
    required this.data,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      message: json['message'] as String,
      data: RegistrationData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }

  // Contoh penggunaan model ini di fungsi main() sementara atau di file test



void main() {
  final String jsonString = """
  {
      "message": "Registrasi berhasil",
      "data": {
          "token": "1|2EbmBFXOcpziGQL4HSKhBeB08qr0um2XFJ1ZTaOh37ca186e",
          "user": {
              "name": "Budi",
              "email": "budi@mail.com",
              "updated_at": "2025-06-19T07:22:40.000000Z",
              "created_at": "2025-06-19T07:22:40.000000Z",
              "id": 2
          }
      }
  }
  """;

  final Map<String, dynamic> jsonMap = json.decode(jsonString);

  // Deserialize JSON ke Dart object
  final RegistrationResponse response = RegistrationResponse.fromJson(jsonMap);

  print('Message: ${response.message}');
  print('Token: ${response.data.token}');
  print('User ID: ${response.data.user.id}'); // Perhatikan ini int dari User
  print('User Name: ${response.data.user.name}');
  print('User Email: ${response.data.user.email}');
  print('User Created At: ${response.data.user.createdAt}');
  print('User Updated At: ${response.data.user.updatedAt}');

  // Serialize Dart object kembali ke JSON (opsional)
  final Map<String, dynamic> serializedJson = response.toJson();
  print('\nSerialized JSON: ${json.encode(serializedJson)}');
}
}
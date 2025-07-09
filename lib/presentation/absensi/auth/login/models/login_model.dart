// import 'dart:convert';

// import 'package:absensi_maps/presentation/absensi/profile/models/user_base.dart' show User;


// // Model untuk objek 'data' dari API response login
// class LoginData {
//   final String token;
//   final User user; // Menggunakan model User yang sudah ada

//   LoginData({
//     required this.token,
//     required this.user,
//   });

//   factory LoginData.fromJson(Map<String, dynamic> json) {
//     return LoginData(
//       token: json['token'] as String,
//       user: User.fromJson(json['user'] as Map<String, dynamic>),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'token': token,
//       'user': user.toJson(),
//     };
//   }
// }

// // Model untuk keseluruhan response API login
// class LoginResponse {
//   final String message;
//   final LoginData data; // Menggunakan LoginData

//   LoginResponse({
//     required this.message,
//     required this.data,
//   });

//   factory LoginResponse.fromJson(Map<String, dynamic> json) {
//     return LoginResponse(
//       message: json['message'] as String,
//       data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'message': message,
//       'data': data.toJson(),
//     };
//   }
// }

// // --- Contoh penggunaan model ini di fungsi main() sementara atau di file test ---
// void main() {
//   final String jsonString = """
//   {
//     "message": "Login berhasil",
//     "data": {
//       "token": "14|zzUM9ra1heamxdO6EcQqmWXEb9eQsqE67NuNWPbV15f2e48d",
//       "user": {
//         "id": 1,
//         "name": "budianduks",
//         "email": "budi@example.com",
//         "email_verified_at": null,
//         "created_at": "2025-04-10T07:01:59.000000Z",
//         "updated_at": "2025-04-11T01:45:42.000000Z"
//       }
//     }
//   }
//   """;

//   final Map<String, dynamic> jsonMap = json.decode(jsonString);

//   // Deserialize JSON ke Dart object
//   final LoginResponse response = LoginResponse.fromJson(jsonMap);

//   print('Pesan: ${response.message}');
//   print('Token: ${response.data.token}');
//   print('ID Pengguna: ${response.data.user.id}');
//   print('Nama Pengguna: ${response.data.user.name}');
//   print('Email Pengguna: ${response.data.user.email}');
//   print('Email Verified At: ${response.data.user.emailVerifiedAt}'); // Akan null
//   print('Dibuat Pada: ${response.data.user.createdAt}');
//   print('Diperbarui Pada: ${response.data.user.updatedAt}');

//   // Serialize Dart object kembali ke JSON (opsional)
//   final Map<String, dynamic> serializedJson = response.toJson();
//   print('\nJSON Serialized: ${json.encode(serializedJson)}');
// }
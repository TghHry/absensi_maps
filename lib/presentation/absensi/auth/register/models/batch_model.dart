// File: lib/models/public_data_models.dart

import 'dart:convert'; // Import ini jika Anda ingin menggunakan json.decode di contoh main()

// Model untuk satu objek Training (pelatihan)
class Training {
  final int id;
  final String title;
  // Anda bisa menambahkan properti lain di sini jika respons API di detailnya memiliki lebih banyak bidang
  // final String? description;

  Training({
    required this.id,
    required this.title,
    // this.description,
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'] as int,
      title: json['title'] as String,
      // description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      // 'description': description,
    };
  }
}

// Model untuk respons API yang berisi daftar Training
class ListTrainingsResponse {
  final String message;
  final List<Training> data;

  ListTrainingsResponse({
    required this.message,
    required this.data,
  });

  factory ListTrainingsResponse.fromJson(Map<String, dynamic> json) {
    return ListTrainingsResponse(
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Training.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((t) => t.toJson()).toList(),
    };
  }
}

// --- Contoh penggunaan model ini dengan data JSON yang Anda berikan ---
void main() {
  final String jsonString = """
  {
      "message": "List data pelatihan",
      "data": [
          {
              "id": 1,
              "title": "Data Management Staff (Operator Komputer)"
          },
          {
              "id": 2,
              "title": "Bahasa Inggris"
          },
          {
              "id": 3,
              "title": "Desainer Grafis Madya"
          },
          {
              "id": 4,
              "title": "Tata Boga"
          },
          {
              "id": 5,
              "title": "Tata Busana"
          },
          {
              "id": 6,
              "title": "Perhotelan"
          },
          {
              "id": 7,
              "title": "Teknisi Komputer"
          },
          {
              "id": 8,
              "title": "Teknisi Jaringan"
          },
          {
              "id": 9,
              "title": "Barista"
          },
          {
              "id": 10,
              "title": "Bahasa Korea"
          },
          {
              "id": 11,
              "title": "Make Up Artist"
          },
          {
              "id": 12,
              "title": "Desainer Multimedia"
          },
          {
              "id": 13,
              "title": "Content Creator"
          },
          {
              "id": 14,
              "title": "Web Programming"
          },
          {
              "id": 15,
              "title": "Digital Marketing"
          },
          {
              "id": 16,
              "title": "Mobile Programming"
          },
          {
              "id": 17,
              "title": "Akuntansi Junior"
          },
          {
              "id": 18,
              "title": "Konstruksi Bangunan dengan CAD"
          }
      ]
  }
  """;

  // Deserialisasi JSON ke Dart object
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  final ListTrainingsResponse response = ListTrainingsResponse.fromJson(jsonMap);

  print('Pesan: ${response.message}');
  print('Jumlah Pelatihan: ${response.data.length}');
  print('Contoh Pelatihan Pertama: ID=${response.data[0].id}, Title=${response.data[0].title}');
  print('Contoh Pelatihan Terakhir: ID=${response.data.last.id}, Title=${response.data.last.title}');

  // Serialisasi Dart object kembali ke JSON (opsional)
  final Map<String, dynamic> serializedJson = response.toJson();
  print('\nSerialized JSON: ${json.encode(serializedJson)}');
}
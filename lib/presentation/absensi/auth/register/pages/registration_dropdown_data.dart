// File: lib/data/registration_dropdown_data.dart

import 'package:absensi_maps/presentation/absensi/auth/register/models/batch_model.dart';
// Import model Training

// Daftar Training (Jurusan) yang hardcoded
// Menggunakan List<Training> agar type-safe dan konsisten dengan model
final List<Training> kTrainingOptions =  [
  Training(id: 1, title: 'Data Management Staff (Operator Komputer)'),
  Training(id: 2, title: 'Bahasa Inggris'),
  Training(id: 3, title: 'Desainer Grafis Madya'),
  Training(id: 4, title: 'Tata Boga'),
  Training(id: 5, title: 'Tata Busana'),
  Training(id: 6, title: 'Perhotelan'),
  Training(id: 7, title: 'Teknisi Komputer'),
  Training(id: 8, title: 'Teknisi Jaringan'),
  Training(id: 9, title: 'Barista'),
  Training(id: 10, title: 'Bahasa Korea'),
  Training(id: 11, title: 'Make Up Artist'),
  Training(id: 12, title: 'Desainer Multimedia'),
  Training(id: 13, title: 'Content Creator'),
  Training(id: 14, title: 'Web Programming'),
  Training(id: 15, title: 'Digital Marketing'),
  Training(id: 16, title: 'Mobile Programming'),
  Training(id: 17, title: 'Akuntansi Junior'),
  Training(id: 18, title: 'Konstruksi Bangunan dengan CAD'),
];

// Daftar Jenis Kelamin yang hardcoded
final List<Map<String, String>> kJenisKelaminOptions = const [
  {'display': 'Laki-laki', 'value': 'L'},
  {'display': 'Perempuan', 'value': 'P'},
];
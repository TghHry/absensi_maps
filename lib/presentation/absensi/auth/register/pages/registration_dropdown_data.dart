// File: lib/data/registration_dropdown_data.dart

import 'package:absensi_maps/models/training_model.dart'; // Untuk model Training/Datum
import 'package:absensi_maps/models/batch_model.dart'; // Untuk model BatchData

// Daftar Training (Jurusan) yang hardcoded
final List<Datum> kTrainingOptions = [
  Datum(id: 1, title: 'Data Management Staff (Operator Komputer)'),
  Datum(id: 2, title: 'Bahasa Inggris'),
  Datum(id: 3, title: 'Desainer Grafis Madya'),
  Datum(id: 4, title: 'Tata Boga'),
  Datum(id: 5, title: 'Tata Busana'),
  Datum(id: 6, title: 'Perhotelan'),
  Datum(id: 7, title: 'Teknisi Komputer'),
  Datum(id: 8, title: 'Teknisi Jaringan'),
  Datum(id: 9, title: 'Barista'),
  Datum(id: 10, title: 'Bahasa Korea'),
  Datum(id: 11, title: 'Make Up Artist'),
  Datum(id: 12, title: 'Desainer Multimedia'),
  Datum(id: 13, title: 'Content Creator'),
  Datum(id: 14, title: 'Web Programming'),
  Datum(id: 15, title: 'Digital Marketing'),
  Datum(id: 16, title: 'Mobile Programming'),
  Datum(id: 17, title: 'Akuntansi Junior'),
  Datum(id: 18, title: 'Konstruksi Bangunan dengan CAD'),
];

// Daftar Batch yang hardcoded
// CONTOH DATA HARDCODED UNTUK 2 BATCH
final List<BatchData> kBatchOptions = [
  // Contoh Batch 1 (disesuaikan sedikit dari screenshot Postman)
  BatchData(
    id: 1,
    batchKe: 'Batch 1 (Juni - Juli 2025)',
    startDate: DateTime(2025, 6, 2),
    endDate: DateTime(2025, 7, 17),
    createdAt: DateTime(2025, 7, 7, 2, 4, 36),
    updatedAt: DateTime(2025, 7, 7, 2, 4, 36),
    // trainings: [], // Jika tidak perlu menyertakan daftar training bersarang di hardcode
  ),
  // Contoh Batch 2 (data dummy)
  BatchData(
    id: 2,
    batchKe: 'Batch 2 (Agustus - Oktober 2025)',
    startDate: DateTime(2025, 8, 1),
    endDate: DateTime(2025, 10, 31),
    createdAt: DateTime.now(), // Gunakan DateTime.now() untuk contoh
    updatedAt: DateTime.now(),
    // trainings: [],
  ),
];


// Daftar Jenis Kelamin yang hardcoded
final List<Map<String, String>> kJenisKelaminOptions = const [
  {'display': 'Laki-laki', 'value': 'L'},
  {'display': 'Perempuan', 'value': 'P'},
];
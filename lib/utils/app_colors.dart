import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF2196F3); // Biru standar Material Design
  static const Color accentColor = Color(0xFFFFC107); // Kuning standar Material Design
  static const Color darkBackground = Color(0xFF212121); // Contoh warna gelap umum
  static const Color lightBackground = Color(0xFFF5F5F5); // Contoh warna terang umum

  // Warna khusus untuk UI Login & Register (dari gambar Anda sebelumnya)
  static const Color loginBackgroundColor = Color(0xFF3F465B); // Abu-abu gelap dari gambar login
  static const Color loginAccentColor = Color(0xFFFCFF2D); // Kuning cerah dari gambar login
  static const Color loginCardColor = Colors.white; // Warna card login/register
  static const Color loginButtonColor = Color(0xFF5373E0); // Biru tombol login/register
  static const Color textLight = Colors.white; // Warna teks terang
  static const Color textDark = Colors.black; // Warna teks gelap

  // --- Tambahan Warna untuk HomePage (dari gambar HomePage Anda) ---
  static const Color homeTopYellow = Color(0xFFFCFF2D); // Kuning cerah di bagian atas HomePage
  static const Color homeTopBlue = Color(0xFF5373E0); // Biru solid di bagian atas HomePage
  static const Color homeCardBackground = Colors.white; // Latar belakang card absensi di HomePage
  static const Color bottomNavBackground = Color(0xFFFCFF2D); // Kuning solid untuk Bottom Navigation Bar
  static const Color bottomNavIconColor = Colors.black; // Warna icon dan teks di Bottom Navigation Bar
  static const Color historyLateRed = Colors.red; // Warna merah untuk jam terlambat di riwayat absensi

  static const Color historyCardBackground = Color(0xFFECEFF1); // Warna abu-abu muda untuk card history
  static const Color historyBlueShape = Color(0xFF5373E0); // Biru untuk shape di History page
  static const Color historyYellowShape = Color(0xFFFCFF2D); // Kuning untuk shape di History page

  // Tambahkan warna lain sesuai kebutuhan aplikasi Anda ke depannya
}
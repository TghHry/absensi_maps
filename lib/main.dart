// lib/main.dart

import 'package:absensi_maps/utils/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:provider/provider.dart'; // <<< HAPUS: Tidak lagi perlu jika tidak ada Provider lain
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- HAPUS: Import ThemeProvider dan AppThemes (jika AppThemes hanya untuk dark mode) ---
// import 'package:absensi_maps/features/app_themes.dart';
// import 'package:absensi_maps/features/theme_provider.dart';

// --- Import Halaman-halaman UI Aplikasi ---
import 'package:absensi_maps/presentation/absensi/auth/login/pages/login_page.dart';
import 'package:absensi_maps/presentation/absensi/auth/password/pages/password_page.dart';
import 'package:absensi_maps/presentation/absensi/auth/register/pages/register_page.dart';

import 'package:absensi_maps/presentation/absensi/home/pages/main_page.dart';

// ***** BARU: Import untuk inisialisasi data lokal DateFormat *****
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ***** BARU: Panggil initializeDateFormatting di sini *****
  await initializeDateFormatting('id_ID', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  final sharedPreferences = await SharedPreferences.getInstance(); // Variabel ini sekarang tidak digunakan di sini, bisa dihapus jika tidak ada keperluan lain
  const flutterSecureStorage = FlutterSecureStorage(); // Variabel ini juga tidak digunakan langsung di sini, bisa dihapus

  // HAPUS Provider dan ThemeProvider, langsung jalankan MyApp
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // HAPUS builder yang berlebihan dan provider
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Absensi',
      // Gunakan hanya lightTheme atau langsung definisikan ThemeData
      theme: ThemeData( // Anda bisa definisikan tema terang di sini, atau buat file AppThemes.dart untuk lightTheme saja
        primarySwatch: Colors.blue, // Contoh primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Tambahkan kustomisasi tema terang lainnya di sini
        // Misalnya:
        // scaffoldBackgroundColor: Colors.white,
        // appBarTheme: AppBarTheme(color: Colors.blueAccent),
        // ...
      ),
      // HAPUS darkTheme dan themeMode
      // darkTheme: AppThemes.darkTheme,
      // themeMode: themeProvider.themeMode,

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/password': (context) => const PasswordPage(),
        
        '/main': (context) => const MainPage(), 
        
        // Halaman-halaman anak tidak perlu dideklarasikan terpisah jika sudah diakses via MainPage
        // '/home': (context) => const HomePage(),
        // '/history': (context) => const HistoryPage(userId: 'dummy_user_id'),
        // '/kehadiran': (context) => const AttandancePage(),
        // '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
// lib/main.dart

import 'package:absensi_maps/utils/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- Import Theme ---
import 'package:absensi_maps/features/app_themes.dart';
import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/features/theme_storage.dart';

// --- Import Halaman-halaman UI Aplikasi ---
import 'package:absensi_maps/presentation/absensi/auth/login/pages/login_page.dart';
import 'package:absensi_maps/presentation/absensi/auth/password/pages/password_page.dart';
import 'package:absensi_maps/presentation/absensi/auth/register/pages/register_page.dart';

import 'package:absensi_maps/presentation/absensi/home/pages/main_page.dart';
import 'package:absensi_maps/presentation/absensi/home/pages/home_page.dart';
import 'package:absensi_maps/presentation/absensi/history/pages/history_page.dart';
import 'package:absensi_maps/presentation/absensi/attandance/pages/attandance_page.dart';
import 'package:absensi_maps/presentation/absensi/profile/pages/profile_page.dart';



// ***** BARU: Import untuk inisialisasi data lokal DateFormat *****
import 'package:intl/date_symbol_data_local.dart'; // <--- TAMBAHKAN INI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ***** BARU: Panggil initializeDateFormatting di sini *****
  await initializeDateFormatting('id_ID', null); // <--- TAMBAHKAN INI (untuk bahasa Indonesia)
                                                // Jika Anda menggunakan lokal lain, sesuaikan 'id_ID'
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  const flutterSecureStorage = FlutterSecureStorage();

  final themeStorage = ThemeStorage(sharedPreferences, flutterSecureStorage);
  final themeProvider = ThemeProvider(themeStorage);

  runApp(
    ChangeNotifierProvider(
      create: (context) => themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Aplikasi Absensi',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/password': (context) => const PasswordPage(),
            
            // ***** KEMBALIKAN KE MAINPAGE YANG SEBENARNYA (jika Anda sudah yakin) *****
            '/main': (context) => const MainPage(), 
            
            '/home': (context) => const HomePage(),
            '/history': (context) => const HistoryPage(userId: 'dummy_user_id'),
            '/kehadiran': (context) => const AttandancePage(),
            '/profile': (context) => const ProfilePage(),
            // '/edit_profile': (context) => const EditProfilePage(currentUser: null), // Rute ini dihapus karena menyebabkan error
          },
        );
      },
    );
  }
}
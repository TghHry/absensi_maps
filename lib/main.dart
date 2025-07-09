import 'package:absensi_maps/utils/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk SystemChrome
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- Import Theme ---
// Sesuaikan jalur import ini jika lokasi file Anda berbeda
import 'package:absensi_maps/features/app_themes.dart';
import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/features/theme_storage.dart';

// --- Import Halaman-halaman UI Aplikasi ---
// Import halaman-halaman Autentikasi
import 'package:absensi_maps/presentation/absensi/auth/login/pages/login_page.dart';
import 'package:absensi_maps/presentation/absensi/auth/password/pages/password_page.dart'; // Asumsi ini NewPasswordPage
import 'package:absensi_maps/presentation/absensi/auth/register/pages/register_page.dart';

// Import halaman-halaman Utama & Fitur
import 'package:absensi_maps/presentation/absensi/home/pages/main_page.dart'; // Ini diasumsikan sebagai MainScreen Anda
import 'package:absensi_maps/presentation/absensi/home/pages/home_page.dart'; // Halaman Home (konten MainScreen)
import 'package:absensi_maps/presentation/absensi/history/pages/history_page.dart'; // Halaman History (konten MainScreen)
import 'package:absensi_maps/presentation/absensi/attandance/pages/attandance_page.dart'; // Halaman Kehadiran (Map/Absensi detail, konten MainScreen)
// import 'package:absensi_maps/presentation/absensi/profile/pages/profile_page.dart'; // Halaman Profile (konten MainScreen)
// import 'package:absensi_maps/presentation/absensi/profile/edit_profile/pages/edit_profile_page.dart'; // Halaman Edit Profile

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi sebelum menggunakan plugin
  WidgetsFlutterBinding.ensureInitialized();

  // --- Konfigurasi Status Bar Sistem (agar transparan dan ikon putih) ---
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Membuat latar belakang status bar transparan
      statusBarIconBrightness:
          Brightness
              .light, // Mengatur warna ikon status bar menjadi terang (putih)
      statusBarBrightness:
          Brightness
              .dark, // Hanya untuk iOS: mengatur teks status bar menjadi terang
    ),
  );

  // --- Inisialisasi Dependensi Utama ---
  final sharedPreferences = await SharedPreferences.getInstance();
  const flutterSecureStorage = FlutterSecureStorage();

  // --- Inisialisasi Theme Feature ---
  final themeStorage = ThemeStorage(sharedPreferences, flutterSecureStorage);
  final themeProvider = ThemeProvider(themeStorage);

  runApp(
    // --- Sediakan ThemeProvider ke seluruh widget tree ---
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
    // Gunakan Consumer untuk membaca ThemeProvider dan menerapkan tema
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false, // Menghilangkan banner debug
          title: 'Aplikasi Absensi', // Judul aplikasi
          theme: AppThemes.lightTheme, // Tema terang
          darkTheme: AppThemes.darkTheme, // Tema gelap
          themeMode: themeProvider.themeMode, // Mode tema dari ThemeProvider
          // --- Konfigurasi Rute Bernama ---
          initialRoute: '/', // Halaman awal aplikasi
          routes: {
            // Rute Autentikasi
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(), // Halaman Login
            '/register': (context) => const RegisterPage(), // Halaman Register
            '/password':
                (context) => const PasswordPage(), // Halaman New Password
            // Rute Utama Aplikasi (setelah Login)
            '/main':
                (context) =>
                    const MainPage(), // Halaman utama dengan BottomNavigationBar
            // Rute untuk konten halaman yang bisa diakses secara langsung (opsional)
            // Namun, untuk navigasi dari BottomNav, halaman ini akan diakses sebagai anak dari MainPage
            '/home':
                (context) => const HomePage(), // Halaman Home (konten MainPage)
            '/history':
                (context) => const HistoryPage(
                  userId: 'dummy_user_id',
                ), // Halaman History (konten MainPage)
            '/kehadiran':
                (context) =>
                    const AttandancePage(), // Halaman Kehadiran (Map/Absensi detail, konten MainPage)
            // '/profile':
            //     (context) =>
            //         const ProfilePage(), // Halaman Profile (konten MainPage)
            // '/edit_profile':
            //     (context) => const EditProfilePage(), // Halaman Edit Profile
          },
        );
      },
    );
  }
}

// import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/presentation/absensi/attandance/pages/attandance_page.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Untuk ThemeProvider

// Import semua halaman konten yang akan diakses dari Bottom Navigation Bar
import 'package:absensi_maps/presentation/absensi/home/pages/home_page.dart'; // Pastikan path ini benar untuk HomePage Anda
import 'package:absensi_maps/presentation/absensi/history/pages/history_page.dart'; // Halaman History Anda
import 'package:absensi_maps/presentation/absensi/profile/pages/profile_page.dart'; // Asumsi halaman Profile Anda

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Index halaman yang sedang aktif

  // Daftar halaman konten yang akan ditampilkan
  // Penting: Halaman-halaman ini TIDAK BOLEH memiliki BottomNavigationBar sendiri
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(), // Index 0: Home
    const AttandancePage(), // Index 1: Map/Absensi
    const HistoryPage(
      userId: 'dummy_user_id',
    ), // Index 2: History (beri dummy userId untuk UI)
    const ProfilePage(), // Index 3: Profile
  ];

  // Callback saat item Bottom Navigation Bar ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update index halaman yang aktif
    });
    // Tidak perlu Navigator.push di sini, cukup ganti _selectedIndex
    // AppBar title bisa disesuaikan per halaman anak, atau di sini
  }

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(
    // context,
    // ); // Untuk toggle tema di AppBar

    return Scaffold(
      body: IndexedStack(
        // IndexedStack menjaga state setiap halaman
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        color: AppColors.bottomNavBackground, // Warna kuning solid
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ), // Menyesuaikan dengan safe area bawah
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: AppColors.bottomNavBackground, // Warna kuning solid
          selectedItemColor:
              AppColors.bottomNavIconColor, // Warna icon dan teks terpilih
          unselectedItemColor: AppColors.bottomNavIconColor.withOpacity(
            0.6,
          ), // Warna icon dan teks tidak terpilih
          type:
              BottomNavigationBarType
                  .fixed, // Penting agar semua item terlihat dan warna solid
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Kehadiran'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

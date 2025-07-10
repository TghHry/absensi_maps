// lib/presentation/absensi/home/pages/main_page.dart

// Pastikan semua import halaman anak AKTIF (tidak dikomentari)
import 'package:absensi_maps/presentation/absensi/attandance/pages/attandance_page.dart';
import 'package:absensi_maps/presentation/absensi/profile/pages/profile_page.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint

// Pastikan semua import halaman anak AKTIF (tidak dikomentari)
import 'package:absensi_maps/presentation/absensi/home/pages/home_page.dart';
import 'package:absensi_maps/presentation/absensi/history/pages/history_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Index halaman yang sedang aktif

  // ***** SOLUSI: KEMBALIKAN KE HALAMAN ASLI ANDA *****
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(), // Memanggil HomePage yang sebenarnya
    AttandancePage(), // Memanggil AttandancePage yang sebenarnya (TANPA 'const')
    const HistoryPage(userId: 'dummy_user_id'), // Memanggil HistoryPage yang sebenarnya
    const ProfilePage(), // Memanggil ProfilePage yang sebenarnya
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('MainPage: initState terpanggil.');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    debugPrint('MainPage: Item tab dipilih: $index');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MainPage: build terpanggil. Index terpilih: $_selectedIndex');

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: Container(
        color: AppColors.bottomNavBackground,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: AppColors.bottomNavBackground,
          selectedItemColor: AppColors.bottomNavIconColor,
          unselectedItemColor: AppColors.bottomNavIconColor.withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Kehadiran'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
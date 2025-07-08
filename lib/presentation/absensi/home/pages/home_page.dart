import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tetap diimpor untuk ThemeProvider
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu
// import 'package:attendance_app/core/util/app_colors.dart'; // Pastikan ini sudah ada dan diperbarui
// Import halaman UI lain yang mungkin diakses dari BottomNav
// import 'package:absensi_maps/presentation/absensi/history/pages/history_page.dart';
// import 'package:attendance_app/features/attendance/presentation/pages/attendance_page.dart'; // Ini halaman untuk Map/Absensi detail

// Enum untuk indeks Bottom Navigation Bar, hanya untuk UI local
enum BottomNavItem { home, map, history, profile }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State lokal untuk Bottom Navigation Bar dan simulasi status absensi
  bool _hasCheckedInToday = true; // UBAH INI: Simulasi status sudah check-in
  // DateTime? _lastCheckInTime; // Simulasi waktu check-in

  // Data riwayat absensi statis (diketik langsung) untuk keperluan tampilan UI
  final List<Map<String, dynamic>> _attendanceHistory = [
    {
      'date': DateTime(2023, 4, 18),
      'check_in': '08:00 AM',
      'check_out': '05:00 PM',
      'is_late': false,
    },
    {
      'date': DateTime(2023, 4, 15),
      'check_in': '08:52 AM',
      'check_out': '05:00 PM',
      'is_late': true,
    }, // Contoh terlambat
    {
      'date': DateTime(2023, 4, 14),
      'check_in': '07:45 AM',
      'check_out': '05:00 PM',
      'is_late': false,
    },
    {
      'date': DateTime(2023, 4, 13),
      'check_in': '07:55 AM',
      'check_out': '05:00 PM',
      'is_late': false,
    },
    {
      'date': DateTime(2023, 4, 12),
      'check_in': '08:48 AM',
      'check_out': '05:00 PM',
      'is_late': true,
    }, // Contoh terlambat
    {
      'date': DateTime(2023, 4, 11),
      'check_in': '07:52 AM',
      'check_out': '05:00 PM',
      'is_late': false,
    },
  ];

  // Fungsi placeholder untuk Check-out (hanya update UI lokal)
  void _performCheckOutUI() {
    setState(() {
      _hasCheckedInToday =
          false; // Setelah check-out, nonaktifkan tombol check-out
      // _lastCheckInTime = null; // Clear last check-in time
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-out Berhasil! (UI Simulasi)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // Hanya untuk toggle tema
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Untuk menampilkan waktu dan tanggal saat ini (real-time dari perangkat)
    final now = DateTime.now();
    final timeFormat = DateFormat('hh:mm a'); // Contoh: 09:41 AM
    final dateFormat = DateFormat(
      'EEE, dd MMMM ',
    ).format(now); // Contoh: Mon, 18 April 2023

    return Scaffold(
      backgroundColor:
          AppColors.lightBackground, // Background abu-abu muda di luar card
      body: Stack(
        children: [
          // Latar belakang kuning di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.35, // Ketinggian relatif
              color: AppColors.homeTopYellow, // Warna kuning solid
            ),
          ),
          // Latar belakang biru di bagian atas dengan sudut melengkung
          Positioned(
            top:
                screenHeight *
                0.15, // Posisi awal blue shape, menutupi sebagian kuning
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.2, // Ketinggian blue shape
              decoration: BoxDecoration(
                color: AppColors.homeTopBlue, // Warna biru solid
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    screenWidth * 0.15,
                  ), // Melengkung di kiri atas
                  topRight: Radius.circular(
                    screenWidth * 0.15,
                  ), // Melengkung di kanan atas
                ),
              ),
            ),
          ),
          // Konten Utama (User Info, Live Attendance Card, History)
          SingleChildScrollView(
            // Memungkinkan konten discroll jika melebihi tinggi layar
            padding: EdgeInsets.only(
              top: screenHeight * 0.08,
            ), // Padding dari atas untuk info user
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info User (Mamat, ID, Jabatan, Icon Logout/Settings)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      // Avatar User
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              Colors
                                  .white, // Background lingkaran putih di bawah avatar
                          border: Border.all(
                            color: AppColors.homeTopBlue,
                            width: 2,
                          ), // Border biru
                        ),
                        child: ClipOval(
                          // Untuk membulatkan gambar
                          child: Image.asset(
                            'assets/images/user_avatar.png', // Pastikan path ini benar dan aset sudah ditambahkan di pubspec.yaml
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey[600],
                              ); // Placeholder jika gambar error
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Nama & Jabatan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mamat',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textLight, // Warna teks putih
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '12345678 - Junior UX Designer',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textLight.withOpacity(
                                0.8,
                              ), // Warna teks putih transparan
                            ),
                          ),
                        ],
                      ),
                      const Spacer(), // Dorong icon ke kanan
                      // Icon Logout/Settings (ikon panah ke kanan di gambar)
                      IconButton(
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: AppColors.textLight,
                          size: 28,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Logout/Settings ditekan (UI saja)',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Jarak ke card absensi
                // Live Attendance Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color:
                        AppColors
                            .homeCardBackground, // Latar belakang card putih
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Sudut membulat card
                    boxShadow: [
                      // Bayangan card
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Attendance',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          timeFormat.format(now), // Waktu saat ini
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                AppColors.homeTopBlue, // Warna biru untuk waktu
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          dateFormat +
                              DateFormat('yyyy').format(
                                now,
                              ), // Tanggal saat ini (Mon, 18 April 2023)
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                      const Divider(height: 30, thickness: 1), // Garis pemisah
                      Text(
                        'Office Hours',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '08:00 AM - 05:00 PM', // Jam kerja statis
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tombol Check Out saja
                      SizedBox(
                        // Menggunakan SizedBox untuk mengatur lebar tombol
                        width:
                            double
                                .infinity, // Membuat tombol mengisi lebar penuh
                        child: ElevatedButton(
                          onPressed:
                              !_hasCheckedInToday
                                  ? null
                                  : _performCheckOutUI, // Nonaktif jika sudah check-out
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.loginButtonColor,
                            foregroundColor: AppColors.textLight,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Check out'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Jarak ke riwayat absensi
                // Attendance History Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.history, size: 24, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        'Attendance History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Tombol toggle tema di sini jika ingin ada di pojok kanan atas
                      IconButton(
                        icon: Icon(
                          themeProvider.themeMode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: () {
                          themeProvider.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Daftar Riwayat Absensi (Menggunakan data statis _attendanceHistory)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _attendanceHistory.length,
                  itemBuilder: (context, index) {
                    final record = _attendanceHistory[index];
                    final recordDate = DateFormat(
                      'EEE, dd MMMM ',
                    ).format(record['date']);
                    final bool isLate = record['is_late'] as bool;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              recordDate +
                                  DateFormat('yyyy').format(record['date']),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${record['check_in']} - ${record['check_out']}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color:
                                    isLate
                                        ? Colors.red
                                        : Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                fontWeight:
                                    isLate
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 100,
                ), // Padding di bawah untuk ruang BottomNav
              ],
            ),
          ),
        ],
      ),
    );
  }
}

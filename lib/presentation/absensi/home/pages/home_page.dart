import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tetap diimpor untuk ThemeProvider
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variabel state ini hanya untuk simulasi internal HomePage
  bool _hasCheckedInToday = false;
  DateTime? _lastCheckInTime;

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
    },
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
    },
    {
      'date': DateTime(2023, 4, 11),
      'check_in': '07:52 AM',
      'check_out': '05:00 PM',
      'is_late': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('HomePage: initState terpanggil.');
  }

  // Metode simulasi ini tidak akan lagi dipanggil dari UI setelah tombol dihapus
  void _performCheckInUI() {
    setState(() {
      _hasCheckedInToday = true;
      _lastCheckInTime = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in Berhasil! (UI Simulasi)')),
    );
  }

  // Metode simulasi ini tidak akan lagi dipanggil dari UI setelah tombol dihapus
  void _performCheckOutUI() {
    setState(() {
      _hasCheckedInToday = false;
      _lastCheckInTime = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-out Berhasil! (UI Simulasi)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomePage: build terpanggil.');
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // Provider tetap diimpor dan digunakan di IconButton
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final now = DateTime.now();
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEE, dd MMMM ');

    // Variabel ini tidak lagi mengontrol tampilan tombol, tetapi bisa tetap ada untuk logika lain jika diperlukan
    bool showCheckInButton = !_hasCheckedInToday;
    bool showCheckOutButton = _hasCheckedInToday;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Latar belakang kuning di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.35,
              color: AppColors.homeTopYellow,
            ),
          ),
          // Latar belakang biru di bagian atas dengan sudut melengkung
          Positioned(
            top: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.2,
              decoration: BoxDecoration(
                color: AppColors.homeTopBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.15),
                  topRight: Radius.circular(screenWidth * 0.15),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: screenHeight * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // Live Attendance Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.homeCardBackground,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
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
                          timeFormat.format(now),
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.homeTopBlue,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          dateFormat.format(now) +
                              DateFormat('yyyy').format(now),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                      const Divider(height: 30, thickness: 1),
                      Text(
                        'Office Hours',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '08:00 AM - 05:00 PM',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Attendance Stats Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Statistik Absensi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: AppColors.homeCardBackground,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(context, 'Total Absen', '20 hari'),
                      _buildStatRow(context, 'Total Masuk', '18 hari'),
                      _buildStatRow(context, 'Total Izin', '2 hari'),
                      _buildStatRow(context, 'Sudah Absen Hari Ini', 'Ya'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

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
                // Daftar Riwayat Absensi
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
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

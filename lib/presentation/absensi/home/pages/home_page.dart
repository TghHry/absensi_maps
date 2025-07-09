import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tetap diimpor untuk ThemeProvider
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu

// Hapus import untuk model dan service absensi, secure_storage, shared_preferences, foundation
// import 'package:absensi_maps/presentation/absensi/attendance/models/attendance_models.dart';
// import 'package:absensi_maps/presentation/absensi/attendance/services/attendance_service.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart'; // debugPrint

// Enum untuk indeks Bottom Navigation Bar (jika digunakan)
enum BottomNavItem { home, map, history, profile }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State lokal untuk simulasi status absensi
  bool _hasCheckedInToday = false; // MULA-MULA: Anggap belum check-in
  DateTime? _lastCheckInTime; // Simulasi waktu check-in (jika sudah check-in)

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

  // Hapus semua variabel dan instance terkait API:
  // AttendanceRecord? _todayAttendance;
  // bool _isLoadingAttendanceStatus = true;
  // String? _attendanceStatusError;
  // List<AttendanceRecord> _attendanceHistoryApi;
  // bool _isLoadingHistory = true;
  // String? _historyError;
  // final AttendanceService _attendanceService = AttendanceService();
  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    // Hapus semua pemanggilan metode async awal
    // _initializeData();
  }

  // Hapus semua metode async yang mengambil data dari API:
  // Future<void> _initializeData() async { ... }
  // Future<void> _loadUserInfo() async { ... }
  // Future<void> _fetchTodayAttendanceStatus() async { ... }
  // Future<void> _fetchAttendanceHistory() async { ... }

  // Fungsi untuk Check-in (hanya update UI lokal)
  void _performCheckInUI() {
    setState(() {
      _hasCheckedInToday = true;
      _lastCheckInTime = DateTime.now(); // Simpan waktu check-in simulasi
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in Berhasil! (UI Simulasi)')),
    );
  }

  // Fungsi untuk Check-out (hanya update UI lokal)
  void _performCheckOutUI() {
    setState(() {
      _hasCheckedInToday = false; // Setelah check-out, reset status check-in
      _lastCheckInTime = null; // Clear waktu check-in
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-out Berhasil! (UI Simulasi)')),
    );
  }

  // Hapus _showIzinReasonDialog() jika tidak digunakan lagi untuk simulasi
  // Future<String?> _showIzinReasonDialog() async { ... }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Untuk menampilkan waktu dan tanggal saat ini (real-time dari perangkat)
    final now = DateTime.now();
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEE, dd MMMM ').format(now);

    // Logika tombol UI murni (simulasi)
    bool showCheckInButton =
        !_hasCheckedInToday; // Tampilkan Check In jika belum check-in
    bool showCheckOutButton =
        _hasCheckedInToday; // Tampilkan Check Out jika sudah check-in
    // Tidak ada pesan "sudah check-out" yang terpisah dalam simulasi ini
    // bool showAlreadyCheckedOutMessage = false; // Atau bisa diatur jika ingin ada simulasi check-out lengkap

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
          // Konten Utama (User Info, Live Attendance Card, History)
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
                          dateFormat + DateFormat('yyyy').format(now),
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
                      // Tombol Check In / Check Out (simulasi UI)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (showCheckInButton) // Tampilkan Check In jika belum check-in
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _performCheckInUI,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.loginButtonColor,
                                  foregroundColor: AppColors.textLight,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Check In'),
                              ),
                            ),
                          if (showCheckInButton && showCheckOutButton)
                            const SizedBox(
                              width: 15,
                            ), // Jarak antar tombol jika keduanya aktif (tidak akan terjadi di simulasi)
                          if (showCheckOutButton) // Tampilkan Check Out jika sudah check-in
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _performCheckOutUI,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.loginButtonColor,
                                  foregroundColor: AppColors.textLight,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Check Out'),
                              ),
                            ),
                          // Jika ingin menampilkan 'Check In Izin' statis, tambahkan di sini
                          // atau sebagai bagian dari _performCheckInUI (jika simulasi lebih lanjut)
                        ],
                      ),
                      const SizedBox(height: 10), // Jarak untuk tombol izin
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Tambahkan logika simulasi atau navigasi ke halaman izin jika ada
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Izin ditekan (UI Simulasi)'),
                              ),
                            );
                          },
                          child: const Text(
                            'Ajukan Izin/Cuti',
                            style: TextStyle(
                              color: AppColors.homeTopBlue, // Warna biru
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Attendance Stats Section (Baru)
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
                      _buildStatRow(
                        context,
                        'Total Absen',
                        '20 hari',
                      ), // Data statis
                      _buildStatRow(
                        context,
                        'Total Masuk',
                        '18 hari',
                      ), // Data statis
                      _buildStatRow(
                        context,
                        'Total Izin',
                        '2 hari',
                      ), // Data statis
                      _buildStatRow(
                        context,
                        'Sudah Absen Hari Ini',
                        'Ya',
                      ), // Data statis
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

  // Widget helper untuk menampilkan baris statistik
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

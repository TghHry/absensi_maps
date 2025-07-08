import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/presentation/absensi/attandance/models/attandance_model.dart';
import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_service.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk mendapatkan user info yang disimpan
import 'package:shared_preferences/shared_preferences.dart'; // Untuk mendapatkan user info yang disimpan

// Enum untuk indeks Bottom Navigation Bar (jika digunakan)
enum BottomNavItem { home, map, history, profile }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Data pengguna dari Shared Preferences
  String _userName = 'Pengguna';
  String _userEmail = 'email@example.com';
  // TODO: Tambahkan variabel untuk ID/Jabatan jika disimpan di SharedPreferences

  // State untuk status absensi hari ini dari API
  AttendanceRecord? _todayAttendance; // Akan menyimpan record absensi hari ini
  bool _isLoadingAttendanceStatus = true; // Untuk loading status absensi hari ini
  String? _attendanceStatusError;

  // Data riwayat absensi dari API
  List<AttendanceRecord> _attendanceHistory = [];
  bool _isLoadingHistory = true;
  String? _historyError;

  final AttendanceService _attendanceService = AttendanceService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences _prefs = SharedPreferences.getInstance() as SharedPreferences; // Akan diinisialisasi di initState


  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Muat info pengguna
    _fetchTodayAttendanceStatus(); // Ambil status absensi hari ini
    _fetchAttendanceHistory(); // Ambil riwayat absensi
  }

  // Fungsi untuk memuat informasi pengguna dari SharedPreferences
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Pengguna';
      _userEmail = prefs.getString('user_email') ?? 'email@example.com';
      // TODO: Muat ID/Jabatan lainnya jika ada
    });
  }

  // Fungsi untuk mendapatkan status absensi hari ini dari API
  Future<void> _fetchTodayAttendanceStatus() async {
    setState(() {
      _isLoadingAttendanceStatus = true;
      _attendanceStatusError = null;
    });
    try {
      // TODO: Anda perlu endpoint GET /api/absen/today untuk ini.
      // Jika endpointnya mengembalikan null jika belum absen, atau record jika sudah.
      // Saat ini, kita masih mensimulasikan status awal.
      // Contoh: final AttendanceRecord? status = await _attendanceService.getTodayAttendance();
      // _todayAttendance = status;

      // Untuk demo: Anggap belum absen sama sekali hari ini
      _todayAttendance = null; // Set this to null or a fetched record
      
      setState(() {
        _isLoadingAttendanceStatus = false;
      });
    } catch (e) {
      debugPrint('Error fetching today attendance status: $e');
      setState(() {
        _attendanceStatusError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingAttendanceStatus = false;
      });
    }
  }

  // Fungsi untuk mendapatkan riwayat absensi dari API
  Future<void> _fetchAttendanceHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });
    try {
      // TODO: Anda perlu endpoint GET /api/history/absen untuk ini
      // Misalnya: final List<AttendanceRecord> fetchedHistory = await _attendanceService.getAttendanceHistory();
      // _attendanceHistory = fetchedHistory;

      // Menggunakan data statis Anda untuk riwayat (sementara, sampai API siap)
      _attendanceHistory = [
        AttendanceRecord(checkInTime: DateTime(2023, 4, 18, 8, 0), checkOutTime: DateTime(2023, 4, 18, 17, 0), checkInAddress: 'Kantor', status: 'masuk'),
        AttendanceRecord(checkInTime: DateTime(2023, 4, 15, 8, 52), checkOutTime: DateTime(2023, 4, 15, 17, 0), checkInAddress: 'Kantor', status: 'masuk'),
        AttendanceRecord(checkInTime: DateTime(2023, 4, 14, 7, 45), checkOutTime: DateTime(2023, 4, 14, 17, 0), checkInAddress: 'Kantor', status: 'masuk'),
        AttendanceRecord(checkInTime: DateTime(2023, 4, 13, 7, 55), checkOutTime: DateTime(2023, 4, 13, 17, 0), checkInAddress: 'Kantor', status: 'masuk'),
        AttendanceRecord(checkInTime: DateTime(2023, 4, 12, 8, 48), checkOutTime: DateTime(2023, 4, 12, 17, 0), checkInAddress: 'Kantor', status: 'masuk'),
        AttendanceRecord(checkInTime: DateTime(2023, 4, 11, 7, 52), checkOutTime: DateTime(2023, 4, 11, 17, 0), checkInAddress: 'Kantor', status: 'masuk'),
      ];

      setState(() {
        _isLoadingHistory = false;
      });
    } catch (e) {
      debugPrint('Error fetching attendance history: $e');
      setState(() {
        _historyError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingHistory = false;
      });
    }
  }

  // Fungsi untuk Check-in (membutuhkan dialog untuk status 'izin')
  void _performCheckIn({required String status}) async {
    String? alasanIzin;
    if (status == 'izin') {
      alasanIzin = await _showIzinReasonDialog();
      if (alasanIzin == null || alasanIzin.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Absensi izin dibatalkan atau alasan tidak diisi.'), backgroundColor: Colors.orange),
        );
        return; // Batalkan jika alasan tidak diisi
      }
    }

    setState(() {
      _isLoadingAttendanceStatus = true;
    });
    try {
      final response = await _attendanceService.checkIn(
        status: status,
        alasanIzin: alasanIzin,
      );
      setState(() {
        _todayAttendance = response.data; // Update status absensi hari ini
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.green),
      );
      _fetchAttendanceHistory(); // Refresh riwayat setelah check-in
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-in gagal: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoadingAttendanceStatus = false;
      });
    }
  }

  // Dialog untuk memasukkan alasan izin
  Future<String?> _showIzinReasonDialog() async {
    TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alasan Izin'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(hintText: 'Masukkan alasan izin Anda'),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Kirim'),
              onPressed: () {
                Navigator.of(context).pop(reasonController.text);
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk Check-out
  void _performCheckOut() async {
    setState(() {
      _isLoadingAttendanceStatus = true;
    });
    try {
      final response = await _attendanceService.checkOut();
      setState(() {
        _todayAttendance = response.data; // Update status absensi hari ini
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.green),
      );
      _fetchAttendanceHistory(); // Refresh riwayat setelah check-out
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-out gagal: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoadingAttendanceStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final now = DateTime.now();
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEE, dd MMMM ').format(now);

    // Menentukan tombol yang tampil berdasarkan _todayAttendance
    bool showCheckInButton = _todayAttendance == null; // Belum ada record hari ini
    bool showCheckOutButton = _todayAttendance != null && _todayAttendance?.checkOutTime == null; // Ada record, tapi belum check-out
    bool showAlreadyCheckedOutMessage = _todayAttendance != null && _todayAttendance?.checkOutTime != null; // Sudah check-out

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.35,
              color: AppColors.homeTopYellow,
            ),
          ),
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
                // User Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.homeTopBlue, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/user_avatar.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person, size: 40, color: Colors.grey[600]);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded( // Menggunakan Expanded agar nama/email tidak overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName, // Tampilkan nama dari state
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis, // Tambahkan ellipsis
                            ),
                            Text(
                              _userEmail, // Tampilkan email dari state
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textLight.withOpacity(0.8),
                                  ),
                              overflow: TextOverflow.ellipsis, // Tambahkan ellipsis
                            ),
                            // TODO: Tampilkan ID/Jabatan jika ada
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app, color: AppColors.textLight, size: 28),
                        onPressed: () {
                          // TODO: Implementasi logout yang sebenarnya (memanggil fungsi logout di LoginPage)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logout ditekan')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.homeTopBlue,
                              ),
                        ),
                      ),
                      Center(
                        child: Text(
                          dateFormat + DateFormat('yyyy').format(now),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ),
                      const Divider(height: 30, thickness: 1),
                      Text(
                        'Office Hours',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '08:00 AM - 05:00 PM',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 20),
                      // Tombol Check In / Check Out / Pesan Sudah Check Out
                      _isLoadingAttendanceStatus
                          ? const Center(child: CircularProgressIndicator())
                          : _attendanceStatusError != null
                              ? Center(
                                  child: Text(_attendanceStatusError!, style: const TextStyle(color: Colors.red)),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (showCheckInButton) // Tampilkan Check In jika belum check-in
                                      Expanded(
                                        child: Column( // Pembungkus untuk 2 tombol check in
                                          children: [
                                            ElevatedButton(
                                              onPressed: () => _performCheckIn(status: 'masuk'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.loginButtonColor,
                                                foregroundColor: AppColors.textLight,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              child: const Text('Check In'),
                                            ),
                                            const SizedBox(height: 10), // Jarak antara tombol
                                            ElevatedButton(
                                              onPressed: () => _performCheckIn(status: 'izin'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.loginAccentColor, // Warna berbeda untuk izin
                                                foregroundColor: AppColors.textDark,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              child: const Text('Check In Izin'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (showCheckOutButton) // Tampilkan Check Out jika sudah check-in dan belum check-out
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _performCheckOut,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.loginButtonColor,
                                            foregroundColor: AppColors.textLight,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          child: const Text('Check Out'),
                                        ),
                                      ),
                                    if (showAlreadyCheckedOutMessage) // Tampilkan pesan jika sudah check-out
                                      Expanded(
                                        child: Text(
                                          'Anda sudah check-out hari ini pada ${DateFormat('HH:mm').format(_todayAttendance!.checkOutTime!)}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                  ],
                                ),
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
                        icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                        onPressed: () {
                          themeProvider.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Daftar Riwayat Absensi
                _isLoadingHistory
                    ? const Center(child: CircularProgressIndicator())
                    : _historyError != null
                        ? Center(
                            child: Text(_historyError!, style: const TextStyle(color: Colors.red)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _attendanceHistory.length,
                            itemBuilder: (context, index) {
                              final record = _attendanceHistory[index];
                              final recordDate = record.checkInTime != null
                                  ? DateFormat('EEE, dd MMMM yyyy').format(record.checkInTime!) // Format tahun
                                  : 'Tanggal Tidak Tersedia';
                              
                              final checkInTimeDisplay = record.checkInTime != null
                                  ? DateFormat('hh:mm a').format(record.checkInTime!)
                                  : 'N/A';
                              final checkOutTimeDisplay = record.checkOutTime != null
                                  ? DateFormat('hh:mm a').format(record.checkOutTime!)
                                  : 'Belum Check Out';

                              final bool isLate = record.checkInTime != null && record.checkInTime!.hour >= 8 && record.checkInTime!.minute > 0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        recordDate,
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '$checkInTimeDisplay - $checkOutTimeDisplay',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              color: isLate ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
                                              fontWeight: isLate ? FontWeight.bold : FontWeight.normal,
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
}
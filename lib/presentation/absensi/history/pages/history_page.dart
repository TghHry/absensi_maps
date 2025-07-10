// File: lib/presentation/absensi/history/pages/history_page.dart

import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_service.dart';
import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/models/attandance_model.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint

// Import model dan service absensi yang sudah dimodifikasi/dibuat

class HistoryPage extends StatefulWidget {
  final String
  userId; // userId ini akan dipakai untuk logika nanti (opsional, karena API hanya butuh token)

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Daftar bulan yang hardcoded (sesuai UI)
  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  String _selectedMonth = DateFormat(
    'MMMM',
    'id_ID',
  ).format(DateTime.now()); // Default: bulan saat ini

  // Data riwayat absensi dari API
  List<Attendance> _attendanceRecords = []; // Menggunakan model Attendance
  bool _isLoadingHistory = true;
  String? _historyError;

  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    // Inisialisasi _selectedMonth agar sesuai dengan indeks _months
    final currentMonthIndex = DateTime.now().month - 1; // Januari = 0
    if (currentMonthIndex >= 0 && currentMonthIndex < _months.length) {
      _selectedMonth = _months[currentMonthIndex];
    } else {
      _selectedMonth = _months[0]; // Fallback ke Januari jika ada masalah
    }

    _fetchHistoryData(_selectedMonth); // Ambil data history untuk bulan default
  }

  // Fungsi untuk mendapatkan nomor bulan dari nama bulan (dalam bahasa Indonesia)
  int _getMonthNumber(String monthName) {
    switch (monthName) {
      case 'Januari':
        return 1;
      case 'Februari':
        return 2;
      case 'Maret':
        return 3;
      case 'April':
        return 4;
      case 'Mei':
        return 5;
      case 'Juni':
        return 6;
      case 'Juli':
        return 7;
      case 'Agustus':
        return 8;
      case 'September':
        return 9;
      case 'Oktober':
        return 10;
      case 'November':
        return 11;
      case 'Desember':
        return 12;
      default:
        return DateTime.now().month; // Fallback ke bulan saat ini
    }
  }

  // Fungsi untuk mengambil data riwayat absensi dari API
  Future<void> _fetchHistoryData(String month) async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
      _attendanceRecords = []; // Kosongkan data sebelumnya
    });

    try {
      final int currentYear = DateTime.now().year;
      final int selectedMonthNumber = _getMonthNumber(month);

      final DateTime startDate = DateTime(currentYear, selectedMonthNumber, 1);
      final DateTime endDate = DateTime(
        currentYear,
        selectedMonthNumber + 1,
        0,
      ); // Hari terakhir bulan

      final String formattedStartDate = DateFormat(
        'yyyy-MM-dd',
      ).format(startDate);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      // Panggil AttendanceService untuk mendapatkan history
      final List<Attendance> fetchedHistory = await _attendanceService
          .getAttendanceHistory(formattedStartDate, formattedEndDate);

      if (!mounted) return;
      setState(() {
        _attendanceRecords = fetchedHistory;
      });
    } catch (e) {
      debugPrint('Error fetching attendance history: $e');
      if (!mounted) return;
      setState(() {
        _historyError = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat riwayat: $_historyError'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  // Fungsi untuk menghapus record absensi
  Future<void> _deleteAttendanceRecord(int recordId) async {
    setState(() {
      _isLoadingHistory = true; // Set loading saat menghapus
    });
    try {
      final Map<String, dynamic> response = await _attendanceService
          .deleteAttendanceRecord(recordId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Absensi berhasil dihapus.'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchHistoryData(_selectedMonth); // Refresh data setelah berhasil hapus
    } catch (e) {
      debugPrint('Error deleting attendance record: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus absensi: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingHistory = false; // Sembunyikan loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Latar belakang kuning dan biru (mirip desain gambar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.4,
              color: AppColors.historyYellowShape,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _HistoryBlueClipper(screenWidth, screenHeight * 0.4),
              child: Container(
                height: screenHeight * 0.4,
                color: AppColors.historyBlueShape,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.35,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.1, // Sesuaikan tinggi ini jika perlu
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.1),
                  topRight: Radius.circular(screenWidth * 0.1),
                ),
              ),
            ),
          ),
          // Konten utama halaman (History Title, Bulan, List Absensi)
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
              ), // Padding disesuaikan agar tidak tertutup AppBar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul "History"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Riwayat Absensi', // Lebih jelas
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.historyBlueShape,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Filter Bulan (Horizontal ListView untuk scrollable tabs)
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      itemCount: _months.length,
                      itemBuilder: (context, index) {
                        final month = _months[index];
                        final isSelected = month == _selectedMonth;
                        return GestureDetector(
                          onTap: () {
                            if (_isLoadingHistory)
                              return; // Nonaktifkan tap saat loading
                            setState(() {
                              _selectedMonth = month;
                            });
                            _fetchHistoryData(
                              month,
                            ); // Panggil API saat bulan berubah
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.historyBlueShape
                                      : AppColors.historyBlueShape.withOpacity(
                                        0.5,
                                      ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white,
                              ), // Tambahkan border agar lebih jelas
                            ),
                            child: Text(
                              month,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color:
                                    isSelected
                                        ? AppColors.historyYellowShape
                                        : Colors.white,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Daftar Absensi
                  _isLoadingHistory // Tampilkan loading jika data sedang diambil
                      ? const Center(child: CircularProgressIndicator())
                      : _historyError !=
                          null // Tampilkan error jika gagal
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _historyError!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : _attendanceRecords
                          .isEmpty // Tampilkan pesan jika tidak ada data
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Tidak ada riwayat absensi untuk bulan $_selectedMonth ini.',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: _attendanceRecords.length,
                        itemBuilder: (context, index) {
                          final record = _attendanceRecords[index];

                          // Pastikan `record.date` tidak null dan bisa di-format
                          final dayOfWeek = DateFormat(
                            'EEEE',
                            'id_ID',
                          ).format(record.date); // <-- Perbaikan
                          final date = DateFormat(
                            'dd-MMM-yy',
                          ).format(record.date); // <-- Perbaikan
                          // Gunakan properti string checkIn dan checkOut dari model Attendance
                          final checkInTimeDisplay = record.checkIn ?? 'N/A';
                          final checkOutTimeDisplay =
                              record.checkOut ?? 'Belum Check Out';

                          // Logika isLate: contoh jika check-in > 08:00 AM
                          // Ini membutuhkan DateTime objek dari check_in (jika ada di model)
                          // Model Attendance Anda memiliki checkIn (String format HH:mm)
                          // Anda perlu parsing kembali atau model Anda perlu menyimpan DateTime asli.
                          // Untuk sementara, saya akan berikan logika sederhana.
                          bool isLate = false;
                          if (record.checkIn != null &&
                              record.checkIn!.contains(':')) {
                            try {
                              final parts = record.checkIn!.split(':');
                              final hour = int.tryParse(parts[0]);
                              final minute = int.tryParse(parts[1]);
                              if (hour != null && minute != null) {
                                if (hour > 8 || (hour == 8 && minute > 0)) {
                                  isLate = true;
                                }
                              }
                            } catch (e) {
                              debugPrint(
                                'Error parsing check-in time for isLate: $e',
                              );
                            }
                          }
                          // Untuk status izin, isLate biasanya tidak berlaku
                          if (record.status == 'izin') {
                            isLate = false;
                          }

                          return Dismissible(
                            key: ValueKey(
                              record.id ,
                            ), // Gunakan ID record dari API
                            direction:
                                DismissDirection
                                    .endToStart, // Geser dari kanan ke kiri untuk hapus
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Konfirmasi Hapus'),
                                    content: const Text(
                                      'Apakah Anda yakin ingin menghapus catatan absensi ini?',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                        
                            },
                            child: HistoryAttendanceCard(
                              dayOfWeek: dayOfWeek,
                              date: date,
                              checkInTime: checkInTimeDisplay,
                              checkOutTime: checkOutTimeDisplay,
                              isLate: isLate,
                              status: record.status, // Teruskan status ke kartu
                              reason:
                                  record
                                      .reason, // Teruskan alasan izin ke kartu
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // Tombol tema (kanan atas)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget terpisah untuk satu kartu riwayat absensi
class HistoryAttendanceCard extends StatelessWidget {
  final String dayOfWeek;
  final String date;
  final String checkInTime;
  final String checkOutTime;
  final bool isLate;
  final String status; // Tambahkan status
  final String? reason; // Tambahkan alasan izin

  const HistoryAttendanceCard({
    super.key,
    required this.dayOfWeek,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.isLate,
    required this.status, // Wajib
    this.reason, // Opsional
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (status == 'izin') {
      statusColor = Colors.orange; // Warna untuk status izin
      statusText = 'Izin';
    } else if (status == 'masuk') {
      if (isLate) {
        statusColor = AppColors.historyLateRed; // Warna untuk terlambat
        statusText = 'Masuk (Terlambat)';
      } else {
        statusColor = Colors.green; // Warna untuk tepat waktu
        statusText = 'Masuk';
      }
    } else {
      statusColor = Colors.grey; // Warna default untuk status tidak diketahui
      statusText = 'Tidak Diketahui';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: AppColors.historyCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayOfWeek,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(
                      0.2,
                    ), // Latar belakang lebih lembut
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (status == 'izin' &&
                reason != null &&
                reason!.isNotEmpty) // Tampilkan alasan jika status izin
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Alasan Izin: $reason',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            const Divider(
              height: 20,
              thickness: 1,
            ), // Divider setelah tanggal dan status
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Rata kanan/kiri
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Tengah untuk waktu
                  children: [
                    Text(
                      'Check In',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      checkInTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            isLate && status == 'masuk'
                                ? AppColors.historyLateRed
                                : null, // Hanya merah jika masuk dan telat
                      ),
                    ),
                  ],
                ),
                // Icon panah atau separator
                Icon(Icons.arrow_right_alt, color: Colors.grey[600]),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Tengah untuk waktu
                  children: [
                    Text(
                      'Check Out',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      checkOutTime,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper untuk memotong bentuk biru di bagian atas (tetap sama)
class _HistoryBlueClipper extends CustomClipper<Path> {
  final double screenWidth;
  final double clipHeight;

  _HistoryBlueClipper(this.screenWidth, this.clipHeight);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.9,
      size.width * 0.5,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.7,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

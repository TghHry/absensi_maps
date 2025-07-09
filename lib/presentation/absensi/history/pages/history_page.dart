import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/presentation/absensi/attandance/models/attandance_model.dart';
import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_service.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

// Import model dan service absensi

import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk mengambil token

class HistoryPage extends StatefulWidget {
  final String userId; // userId ini akan dipakai untuk logika nanti

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Daftar bulan yang hardcoded (sesuai UI)
  final List<String> _months = [
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  String _selectedMonth = 'Juni'; // Bulan yang aktif secara default

  // Data riwayat absensi dari API
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoadingHistory = true;
  String? _historyError;

  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _fetchHistoryData(_selectedMonth); // Ambil data history untuk bulan default
  }

  // Fungsi untuk mengambil data riwayat absensi dari API
  Future<void> _fetchHistoryData(String month) async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
      _attendanceRecords = []; // Kosongkan data sebelumnya
    });

    try {
      // Tentukan tanggal awal dan akhir bulan yang dipilih
      final int currentYear = DateTime.now().year; // Asumsi tahun saat ini
      final int selectedMonthNumber = _months.indexOf(month) + 6; // Juni (0) -> Bulan 6, dst.

      final DateTime startDate = DateTime(currentYear, selectedMonthNumber, 1);
      final DateTime endDate = DateTime(currentYear, selectedMonthNumber + 1, 0); // Hari terakhir bulan

      final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      final List<AttendanceRecord> fetchedHistory = await _attendanceService.getAttendanceHistory(
        formattedStartDate,
        formattedEndDate,
      );

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
        SnackBar(content: Text('Gagal memuat riwayat: $_historyError'), backgroundColor: Colors.red),
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
    try {
      final response = await _attendanceService.deleteAttendanceRecord(recordId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.green),
      );
      // Setelah berhasil hapus di API, refresh data di UI
      _fetchHistoryData(_selectedMonth);
    } catch (e) {
      debugPrint('Error deleting attendance record: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus absensi: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.red),
      );
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
              height: screenHeight * 0.1,
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
              padding: EdgeInsets.only(top: screenHeight * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul "History"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'History',
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
                            setState(() {
                              _selectedMonth = month;
                            });
                            _fetchHistoryData(month); // Panggil API saat bulan berubah
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.historyBlueShape.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              month,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isSelected ? AppColors.historyYellowShape : Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                      : _historyError != null // Tampilkan error jika gagal
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
                          : _attendanceRecords.isEmpty // Tampilkan pesan jika tidak ada data
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
                                    
                                    // Pastikan checkInTime tidak null sebelum format
                                    final dayOfWeek = record.checkInTime != null 
                                      ? DateFormat('EEEE').format(record.checkInTime!) 
                                      : 'N/A';
                                    final date = record.checkInTime != null 
                                      ? DateFormat('dd-MMM-yy').format(record.checkInTime!) 
                                      : 'N/A';
                                    
                                    final checkInTimeDisplay = record.checkInTime != null
                                        ? DateFormat('hh:mm a').format(record.checkInTime!)
                                        : 'N/A';
                                    final checkOutTimeDisplay = record.checkOutTime != null
                                        ? DateFormat('hh:mm a').format(record.checkOutTime!)
                                        : 'Belum Check Out';
                                    
                                    // Logika isLate: contoh jika check-in > 08:00 AM
                                    final bool isLate = record.checkInTime != null && 
                                                        record.checkInTime!.hour >= 8 && 
                                                        record.checkInTime!.minute > 0;

                                    return Dismissible(
                                      key: ValueKey(record.id ?? UniqueKey()), // Gunakan ID record dari API
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        color: Colors.red,
                                        child: const Icon(Icons.delete, color: Colors.white),
                                      ),
                                      confirmDismiss: (direction) async {
                                        return await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Konfirmasi Hapus'),
                                              content: const Text('Apakah Anda yakin ingin menghapus catatan absensi ini?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('Batal'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      onDismissed: (direction) {
                                        if (record.id != null) { // Pastikan ID record tidak null sebelum menghapus
                                          _deleteAttendanceRecord(record.id!); // Panggil fungsi hapus
                                        } else {
                                          // Jika ID null (mock data tanpa ID), hapus dari UI saja
                                          setState(() {
                                            _attendanceRecords.removeAt(index);
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Catatan absensi dihapus dari UI (tanpa ID)')),
                                          );
                                        }
                                      },
                                      child: HistoryAttendanceCard(
                                        dayOfWeek: dayOfWeek,
                                        date: date,
                                        checkInTime: checkInTimeDisplay, // Gunakan display string
                                        checkOutTime: checkOutTimeDisplay, // Gunakan display string
                                        isLate: isLate,
                                      ),
                                    );
                                  },
                                ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
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

// Widget terpisah untuk satu kartu riwayat absensi (tetap sama)
class HistoryAttendanceCard extends StatelessWidget {
  final String dayOfWeek;
  final String date;
  final String checkInTime;
  final String checkOutTime;
  final bool isLate;

  const HistoryAttendanceCard({
    super.key,
    required this.dayOfWeek,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.isLate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: AppColors.historyCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check In',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      checkInTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isLate ? AppColors.historyLateRed : null,
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check Out',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      checkOutTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isLate ? AppColors.historyLateRed : null,
                          ),
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
      size.width * 0.2, size.height * 0.9,
      size.width * 0.5, size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.7,
      size.width, size.height * 0.4,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
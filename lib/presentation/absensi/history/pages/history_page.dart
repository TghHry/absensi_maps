// File: lib/presentation/absensi/history/pages/history_page.dart

// import 'package:absensi_maps/models/generic_api_service.dart';
import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_service.dart';
import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/models/attandance_model.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
// Jangan lupa import GenericApiResponse jika Anda membuatnya di file terpisah

class HistoryPage extends StatefulWidget {
  final String
  userId; // userId ini akan dipakai untuk logika nanti (opsional, karena API hanya butuh token)

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
  String _selectedMonth = DateFormat('MMMM', 'id_ID').format(DateTime.now());

  List<Attendance> _attendanceRecords = [];
  bool _isLoadingHistory = true;
  String? _historyError;

  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    final currentMonthIndex = DateTime.now().month - 1;
    if (currentMonthIndex >= 0 && currentMonthIndex < _months.length) {
      _selectedMonth = _months[currentMonthIndex];
    } else {
      _selectedMonth = _months[0];
    }

    _fetchHistoryData(_selectedMonth);
  }

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
        return DateTime.now().month;
    }
  }

  Future<void> _fetchHistoryData(String month) async {
    if (!mounted) return;
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
      _attendanceRecords = [];
    });

    try {
      final int currentYear = DateTime.now().year;
      final int selectedMonthNumber = _getMonthNumber(month);

      final DateTime startDate = DateTime(currentYear, selectedMonthNumber, 1);
      final DateTime endDate = DateTime(
        currentYear,
        selectedMonthNumber + 1,
        0,
      );

      final String formattedStartDate = DateFormat(
        'yyyy-MM-dd',
      ).format(startDate);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

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
  // Future<void> _deleteAttendanceRecord(int recordId) async {
  //   debugPrint('HistoryPage: Mencoba menghapus record dengan ID: $recordId');
  //   setState(() {
  //     _isLoadingHistory = true; // Set loading saat menghapus
  //   });
  //   try {
  //     // PERUBAHAN: Sekarang memanggil AttendanceService yang mengembalikan GenericApiResponse
  //     final GenericApiResponse response = await _attendanceService.deleteAttendanceRecord(recordId);

  //     debugPrint('HistoryPage: Respon dari deleteAttendanceRecord: ${response.message}');
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(response.message), // Menggunakan response.message dari model
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     // Setelah berhasil hapus di API, refresh data di UI
  //     _fetchHistoryData(_selectedMonth);
  //   } catch (e) {
  //     debugPrint('HistoryPage: Error deleting attendance record: $e');
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Gagal menghapus absensi: ${e.toString().replaceFirst('Exception: ', '')}',
  //         ),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     if (!mounted) return;
  //     setState(() {
  //       _isLoadingHistory = false; // Sembunyikan loading
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/dashboard.jpg', // Path ke gambar Anda
              fit: BoxFit.cover, // Menutupi seluruh area
            ),
          ),

          // Konten utama halaman (History Title, Bulan, List Absensi)
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () => _fetchHistoryData(_selectedMonth),
              color: AppColors.historyBlueShape,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul "History"
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Riwayat Absensi',
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
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
                              if (_isLoadingHistory) return;
                              setState(() {
                                _selectedMonth = month;
                              });
                              _fetchHistoryData(month);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.historyBlueShape
                                        : AppColors.historyBlueShape
                                            .withOpacity(0.5),
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
                    _isLoadingHistory
                        ? const Center(child: CircularProgressIndicator())
                        : _historyError != null
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
                        : _attendanceRecords.isEmpty
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

                            final dayOfWeek = DateFormat(
                              'EEEE',
                              'id_ID',
                            ).format(record.date);
                            final date = DateFormat(
                              'dd-MMM-yy',
                            ).format(record.date);
                            final checkInTimeDisplay = record.checkIn ?? 'N/A';
                            final checkOutTimeDisplay =
                                record.checkOut ?? 'Belum Check Out';

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
                            if (record.status == 'izin') {
                              isLate = false;
                            }

                            return Dismissible(
                              key: ValueKey(record.id),
                              direction: DismissDirection.endToStart,
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
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
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
                              // --- PERBAIKAN PENTING DI SINI ---
                              onDismissed: (direction) {
                                // Panggil metode untuk menghapus record absensi
                                // _deleteAttendanceRecord(record.id);
                              },
                              // ----------------------------------
                              child: HistoryAttendanceCard(
                                dayOfWeek: dayOfWeek,
                                date: date,
                                checkInTime: checkInTimeDisplay,
                                checkOutTime: checkOutTimeDisplay,
                                isLate: isLate,
                                status: record.status,
                                reason: record.reason,
                              ),
                            );
                          },
                        ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          // Tombol tema (kanan atas)
          // Positioned(
          //   top: MediaQuery.of(context).padding.top + 10,
          //   right: 10,
          //   child: IconButton(
          //     icon: Icon(

          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       themeProvider.toggleTheme();
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.historyBlueShape, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ],
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
  final String status;
  final String? reason;

  const HistoryAttendanceCard({
    super.key,
    required this.dayOfWeek,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.isLate,
    required this.status,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (status == 'izin') {
      statusColor = Colors.orange;
      statusText = 'Izin';
    } else if (status == 'masuk') {
      if (isLate) {
        statusColor = AppColors.historyLateRed;
        statusText = 'Masuk (Terlambat)';
      } else {
        statusColor = Colors.green;
        statusText = 'Masuk';
      }
    } else {
      statusColor = Colors.grey;
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
                    color: statusColor.withOpacity(0.2),
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
            if (status == 'izin' && reason != null && reason!.isNotEmpty)
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
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                : null,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_right_alt, color: Colors.grey[600]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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

// Custom Clipper untuk memotong bentuk biru di bagian atas
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

import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tetap diimpor untuk ThemeProvider
import 'package:intl/intl.dart'; // Untuk format tanggal


// Jika Anda ingin navigasi kembali ke halaman lain dari tombol BottomNav di MainScreen,
// pastikan halaman-halaman tersebut sudah diimpor di MainScreen.
// Di halaman ini, kita tidak lagi memiliki BottomNavigationBar secara langsung.


class HistoryPage extends StatefulWidget {
  // userId ini akan dipakai untuk logika nanti, untuk UI bisa dummy saja
  final String userId;

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Data statis untuk filter bulan
  final List<String> _months = ['Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  String _selectedMonth = 'Juni'; // Bulan yang aktif secara default sesuai gambar terbaru

  // Data riwayat absensi statis untuk tampilan UI
  final List<Map<String, dynamic>> _mockHistoryData = [
    // Contoh data untuk bulan Juni
    {'date': DateTime(2025, 6, 13), 'check_in': '07:50:00', 'check_out': '17:50:00', 'is_late': false},
    {'date': DateTime(2025, 6, 12), 'check_in': '07:50:00', 'check_out': '17:50:00', 'is_late': false},
    {'date': DateTime(2025, 6, 11), 'check_in': '07:50:00', 'check_out': '17:50:00', 'is_late': false},
    {'date': DateTime(2025, 6, 10), 'check_in': '07:50:00', 'check_out': '17:50:00', 'is_late': false},
    {'date': DateTime(2025, 6, 9), 'check_in': '07:50:00', 'check_out': '17:50:00', 'is_late': false},
    // Contoh data untuk bulan Juli
    {'date': DateTime(2025, 7, 1), 'check_in': '08:05:00', 'check_out': '17:00:00', 'is_late': true},
    {'date': DateTime(2025, 7, 2), 'check_in': '07:45:00', 'check_out': '17:30:00', 'is_late': false},
  ];

  // Fungsi untuk memfilter data berdasarkan bulan yang dipilih
  List<Map<String, dynamic>> _getFilteredHistory() {
    // Sesuaikan indeks bulan: Juni (0) -> Bulan 6, Juli (1) -> Bulan 7, dst.
    // Tambah 6 karena Juni adalah bulan ke-6
    final int selectedMonthNumber = _months.indexOf(_selectedMonth) + 6;
    return _mockHistoryData.where((record) => record['date'].month == selectedMonthNumber).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Untuk kebutuhan tema
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredHistory = _getFilteredHistory();

    return Scaffold(
      backgroundColor: AppColors.lightBackground, // Background abu-abu muda
      body: Stack(
        children: [
          // Latar belakang kuning dan biru (mirip desain gambar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.4, // Ketinggian area atas
              color: AppColors.historyYellowShape, // Warna kuning
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _HistoryBlueClipper(screenWidth, screenHeight * 0.4), // Custom clipper untuk bentuk biru
              child: Container(
                height: screenHeight * 0.4,
                color: AppColors.historyBlueShape, // Warna biru
              ),
            ),
          ),
          // Bentuk putih melengkung di bagian bawah area header
          Positioned(
            top: screenHeight * 0.35, // Posisikan sedikit di atas card
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.1, // Ketinggian bentuk putih
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
              padding: EdgeInsets.only(top: screenHeight * 0.08), // Padding dari atas untuk judul
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul "History"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'History',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.historyBlueShape, // Warna biru
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Filter Bulan (Horizontal ListView untuk scrollable tabs)
                  SizedBox(
                    height: 50, // Tinggi untuk baris bulan
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
                  if (filteredHistory.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Tidak ada riwayat absensi untuk bulan ini.',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true, // Penting agar ListView bisa di dalam SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll ListView
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final record = filteredHistory[index];
                        final dayOfWeek = DateFormat('EEEE').format(record['date']); // Monday
                        final date = DateFormat('dd-MMM-yy').format(record['date']); // 13-Jun-25

                        return HistoryAttendanceCard(
                          dayOfWeek: dayOfWeek,
                          date: date,
                          checkInTime: record['check_in'],
                          checkOutTime: record['check_out'],
                          isLate: record['is_late'],
                        );
                      },
                    ),
                  const SizedBox(height: 100), // Padding di bawah untuk BottomNav
                ],
              ),
            ),
          ),
          // Tombol toggle tema di pojok kanan atas, jika diinginkan di sini
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Posisi dari atas
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
      // BottomNavigationBar tidak lagi ada di sini, sudah dipindahkan ke MainScreen
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
      color: AppColors.historyCardBackground, // Warna abu-abu muda untuk card
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
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
                            color: isLate ? AppColors.historyLateRed : null, // Merah jika terlambat
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
                            color: isLate ? AppColors.historyLateRed : null, // Merah jika terlambat
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

// Custom Clipper untuk memotong bentuk biru di bagian atas
class _HistoryBlueClipper extends CustomClipper<Path> {
  final double screenWidth;
  final double clipHeight; // Tinggi total area yang di-clip (misal screenHeight * 0.4)

  _HistoryBlueClipper(this.screenWidth, this.clipHeight);

  @override
  Path getClip(Size size) {
    Path path = Path();
    // Gambar bentuk biru sesuai gambar
    // Perhatikan koordinat untuk menciptakan lekukan yang diinginkan

    path.lineTo(0, size.height * 0.6); // Mulai garis lurus dari kiri atas ke bawah
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.9, // Titik kontrol untuk lekukan pertama
      size.width * 0.5, size.height * 0.8, // Titik akhir lekukan pertama
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.7, // Titik kontrol untuk lekukan kedua
      size.width, size.height * 0.4, // Titik akhir lekukan kedua, menuju kanan atas
    );
    path.lineTo(size.width, 0); // Garis lurus ke kanan atas
    path.close(); // Tutup path

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
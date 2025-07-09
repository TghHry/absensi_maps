// import 'package:absensi_maps/features/theme_provider.dart';
// import 'package:absensi_maps/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// class HistoryPage extends StatefulWidget {
//   final String userId; // userId ini akan dipakai untuk logika nanti

//   const HistoryPage({super.key, required this.userId});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   final List<String> _months = [
//     'Juni',
//     'Juli',
//     'Agustus',
//     'September',
//     'Oktober',
//     'November',
//     'Desember',
//   ];
//   String _selectedMonth = 'Juni';

//   // UBAH INI: Deklarasikan _mockHistoryData agar bisa diubah (tidak final)
//   List<Map<String, dynamic>> _mockHistoryData = [
//     {
//       'date': DateTime(2025, 6, 13),
//       'check_in': '07:50:00',
//       'check_out': '17:50:00',
//       'is_late': false,
//     },
//     {
//       'date': DateTime(2025, 6, 12),
//       'check_in': '07:50:00',
//       'check_out': '17:50:00',
//       'is_late': false,
//     },
//     {
//       'date': DateTime(2025, 6, 11),
//       'check_in': '07:50:00',
//       'check_out': '17:50:00',
//       'is_late': false,
//     },
//     {
//       'date': DateTime(2025, 6, 10),
//       'check_in': '07:50:00',
//       'check_out': '17:50:00',
//       'is_late': false,
//     },
//     {
//       'date': DateTime(2025, 6, 9),
//       'check_in': '07:50:00',
//       'check_out': '17:50:00',
//       'is_late': false,
//     },
//     {
//       'date': DateTime(2025, 7, 1),
//       'check_in': '08:05:00',
//       'check_out': '17:00:00',
//       'is_late': true,
//     },
//     {
//       'date': DateTime(2025, 7, 2),
//       'check_in': '07:45:00',
//       'check_out': '17:30:00',
//       'is_late': false,
//     },
//     // Tambahkan lebih banyak data untuk bulan lain jika diperlukan
//     {
//       'date': DateTime(2025, 8, 5),
//       'check_in': '07:55:00',
//       'check_out': '17:00:00',
//       'is_late': false,
//     },
//     {
//       'date': DateTime(2025, 9, 1),
//       'check_in': '08:10:00',
//       'check_out': '17:00:00',
//       'is_late': true,
//     },
//   ];

//   List<Map<String, dynamic>> _getFilteredHistory() {
//     final int selectedMonthNumber =
//         _months.indexOf(_selectedMonth) + 6; // Juni (0) -> Bulan 6, dst.
//     return _mockHistoryData
//         .where((record) => record['date'].month == selectedMonthNumber)
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     final filteredHistory = _getFilteredHistory();

//     return Scaffold(
//       backgroundColor: AppColors.lightBackground,
//       body: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: screenHeight * 0.4,
//               color: AppColors.historyYellowShape,
//             ),
//           ),
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: ClipPath(
//               clipper: _HistoryBlueClipper(screenWidth, screenHeight * 0.4),
//               child: Container(
//                 height: screenHeight * 0.4,
//                 color: AppColors.historyBlueShape,
//               ),
//             ),
//           ),
//           Positioned(
//             top: screenHeight * 0.35,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: screenHeight * 0.1,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(screenWidth * 0.1),
//                   topRight: Radius.circular(screenWidth * 0.1),
//                 ),
//               ),
//             ),
//           ),
//           Positioned.fill(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.only(top: screenHeight * 0.08),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                     child: Text(
//                       'History',
//                       style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                         color: AppColors.historyBlueShape,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     height: 50,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                       itemCount: _months.length,
//                       itemBuilder: (context, index) {
//                         final month = _months[index];
//                         final isSelected = month == _selectedMonth;
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _selectedMonth = month;
//                             });
//                           },
//                           child: Container(
//                             alignment: Alignment.center,
//                             margin: const EdgeInsets.symmetric(horizontal: 5.0),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20.0,
//                               vertical: 8.0,
//                             ),
//                             decoration: BoxDecoration(
//                               color:
//                                   isSelected
//                                       ? Colors.white
//                                       : AppColors.historyBlueShape.withOpacity(
//                                         0.5,
//                                       ),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Text(
//                               month,
//                               style: Theme.of(
//                                 context,
//                               ).textTheme.titleMedium?.copyWith(
//                                 color:
//                                     isSelected
//                                         ? AppColors.historyYellowShape
//                                         : Colors.white,
//                                 fontWeight:
//                                     isSelected
//                                         ? FontWeight.bold
//                                         : FontWeight.normal,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   if (filteredHistory.isEmpty)
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Text(
//                           'Tidak ada riwayat absensi untuk bulan ini.',
//                           style: Theme.of(context).textTheme.titleMedium,
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     )
//                   else
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                       itemCount: filteredHistory.length,
//                       itemBuilder: (context, index) {
//                         final record = filteredHistory[index];
//                         final dayOfWeek = DateFormat(
//                           'EEEE',
//                         ).format(record['date']);
//                         final date = DateFormat(
//                           'dd-MMM-yy',
//                         ).format(record['date']);

//                         // UBAH INI: Bungkus HistoryAttendanceCard dengan Dismissible
//                         return Dismissible(
//                           key: Key(
//                             record['date'].toIso8601String(),
//                           ), // Kunci unik
//                           direction:
//                               DismissDirection
//                                   .endToStart, // Geser dari kanan ke kiri
//                           background: Container(
//                             alignment: Alignment.centerRight,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20.0,
//                             ),
//                             color:
//                                 Colors.red, // Latar belakang merah saat digeser
//                             child: const Icon(
//                               Icons.delete,
//                               color: Colors.white,
//                             ),
//                           ),
//                           confirmDismiss: (direction) async {
//                             return await showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: const Text('Konfirmasi Hapus'),
//                                   content: const Text(
//                                     'Apakah Anda yakin ingin menghapus catatan absensi ini?',
//                                   ),
//                                   actions: <Widget>[
//                                     TextButton(
//                                       onPressed:
//                                           () => Navigator.of(
//                                             context,
//                                           ).pop(false), // Batal
//                                       child: const Text('Batal'),
//                                     ),
//                                     ElevatedButton(
//                                       onPressed:
//                                           () => Navigator.of(
//                                             context,
//                                           ).pop(true), // Konfirmasi
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.red,
//                                       ),
//                                       child: const Text('Hapus'),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           },
//                           onDismissed: (direction) {
//                             // Hapus item dari daftar dan perbarui UI
//                             setState(() {
//                               _mockHistoryData.remove(
//                                 record,
//                               ); // Hapus dari data sumber utama
//                               // Jika Anda menggunakan filteredHistory sebagai sumber data, Anda harus menghapusnya dari _mockHistoryData
//                               // Atau panggil _getFilteredHistory() lagi setelah penghapusan untuk me-refresh tampilan.
//                               // Cara yang lebih aman adalah bekerja langsung dengan _mockHistoryData dan memfilter ulang.
//                             });
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   'Catatan absensi ${dayOfWeek}, ${date} telah dihapus',
//                                 ),
//                               ),
//                             );
//                             // TODO: Di sini, Anda akan memanggil API DELETE absensi yang sebenarnya
//                             // _attendanceService.deleteAttendanceRecord(record['id']);
//                           },
//                           child: HistoryAttendanceCard(
//                             dayOfWeek: dayOfWeek,
//                             date: date,
//                             checkInTime: record['check_in'],
//                             checkOutTime: record['check_out'],
//                             isLate: record['is_late'],
//                           ),
//                         );
//                       },
//                     ),
//                   const SizedBox(height: 100),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 10,
//             right: 10,
//             child: IconButton(
//               icon: Icon(
//                 themeProvider.themeMode == ThemeMode.dark
//                     ? Icons.light_mode
//                     : Icons.dark_mode,
//                 color: Colors.white,
//               ),
//               onPressed: () {
//                 themeProvider.toggleTheme();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Widget terpisah untuk satu kartu riwayat absensi
// class HistoryAttendanceCard extends StatelessWidget {
//   final String dayOfWeek;
//   final String date;
//   final String checkInTime;
//   final String checkOutTime;
//   final bool isLate;

//   const HistoryAttendanceCard({
//     super.key,
//     required this.dayOfWeek,
//     required this.date,
//     required this.checkInTime,
//     required this.checkOutTime,
//     required this.isLate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       color: AppColors.historyCardBackground,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   dayOfWeek,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   date,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Check In',
//                       style: Theme.of(
//                         context,
//                       ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
//                     ),
//                     Text(
//                       checkInTime,
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         color: isLate ? AppColors.historyLateRed : null,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 20),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Check Out',
//                       style: Theme.of(
//                         context,
//                       ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
//                     ),
//                     Text(
//                       checkOutTime,
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         color: isLate ? AppColors.historyLateRed : null,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Custom Clipper untuk memotong bentuk biru di bagian atas
// class _HistoryBlueClipper extends CustomClipper<Path> {
//   final double screenWidth;
//   final double clipHeight;

//   _HistoryBlueClipper(this.screenWidth, this.clipHeight);

//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height * 0.6);
//     path.quadraticBezierTo(
//       size.width * 0.2,
//       size.height * 0.9,
//       size.width * 0.5,
//       size.height * 0.8,
//     );
//     path.quadraticBezierTo(
//       size.width * 0.7,
//       size.height * 0.7,
//       size.width,
//       size.height * 0.4,
//     );
//     path.lineTo(size.width, 0);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }

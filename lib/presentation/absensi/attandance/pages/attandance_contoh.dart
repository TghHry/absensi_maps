// import 'package:absensi_maps/presentation/absensi/attandance/models/attandance_model.dart';
// import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_service.dart';
// import 'package:absensi_maps/utils/app_colors.dart' show AppColors;
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart'; // Untuk mendapatkan lokasi
// import 'package:geocoding/geocoding.dart'; // Untuk mendapatkan alamat dari lat/lng
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu
// import 'package:flutter/foundation.dart'; // Untuk debugPrint

// class AttandancePage extends StatefulWidget {
//   const AttandancePage({super.key});

//   @override
//   State<AttandancePage> createState() => _AttandancePageState();
// }

// class _AttandancePageState extends State<AttandancePage> {
//   GoogleMapController? mapController;
//   final Set<Marker> _markers = {};

//   final TextEditingController _noteController = TextEditingController();

//   // State untuk data absensi dan lokasi
//   AttendanceRecord? _todayAttendance; // Record absensi hari ini dari API
//   String _currentAddress =
//       'Mendapatkan lokasi...'; // Alamat yang didapat dari GPS
//   double? _currentLat; // Latitude saat ini
//   double? _currentLng; // Longitude saat ini

//   // State untuk loading dan error
//   bool _isFetchingInitialData =
//       true; // Loading awal untuk lokasi & status absen
//   bool _isLoadingApiAction = false; // Loading untuk tombol Check In/Out
//   String? _errorMessage; // Pesan error jika ada masalah

//   // Services
//   final AttendanceService _attendanceService = AttendanceService();

//   @override
//   void initState() {
//     super.initState();
//     _initializePageData(); // Memulai proses pengambilan data awal
//   }

//   @override
//   void dispose() {
//     _noteController.dispose();
//     mapController?.dispose();
//     super.dispose();
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     // Pindahkan kamera ke lokasi pengguna setelah peta dibuat
//     if (_currentLat != null && _currentLng != null) {
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(LatLng(_currentLat!, _currentLng!), 17.0),
//       );
//     }
//   }

//   // --- Metode Inisialisasi dan Pengambilan Data ---
//   Future<void> _initializePageData() async {
//     setState(() {
//       _isFetchingInitialData = true;
//       _errorMessage = null;
//     });

//     try {
//       final Position position = await _getCurrentLocation();
//       _currentLat = position.latitude;
//       _currentLng = position.longitude;

//       _updateMapToCurrentLocation();
//       await _getAddressFromLatLng(position);
//       await _fetchTodayAttendanceStatus();
//     } catch (e) {
//       debugPrint('Error initializing AttandancePage: $e');
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = e.toString().replaceFirst('Exception: ', '');
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $_errorMessage'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isFetchingInitialData = false;
//       });
//     }
//   }

//   Future<Position> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error(
//         'Layanan lokasi tidak diaktifkan. Mohon aktifkan GPS Anda.',
//       );
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Izin lokasi ditolak. Mohon izinkan akses lokasi.');
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//         'Izin lokasi ditolak secara permanen. Mohon ubah di pengaturan aplikasi.',
//       );
//     }

//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }

//   // Mengkonversi lat/lng menjadi alamat (reverse geocoding)
//   Future<void> _getAddressFromLatLng(Position position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//         // Menambahkan timeout untuk geocoding jika ada masalah
//         // localeIdentifier: 'id_ID', // Opsional: Untuk bahasa Indonesia
//       );
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         if (!mounted) return;
//         setState(() {
//           _currentAddress =
//               "${place.street ?? ''}, ${place.subLocality ?? ''}, "
//               "${place.locality ?? ''}, ${place.administrativeArea ?? ''} ${place.postalCode ?? ''}, ${place.country ?? ''}";
//           _markers.clear();
//           _markers.add(
//             Marker(
//               markerId: const MarkerId('currentLocation'),
//               position: LatLng(position.latitude, position.longitude),
//               infoWindow: InfoWindow(title: _currentAddress),
//             ),
//           );
//         });
//       } else {
//         if (!mounted) return;
//         setState(() {
//           _currentAddress = 'Alamat tidak ditemukan (data kosong).';
//         });
//       }
//     } catch (e) {
//       debugPrint('Error getting address from location: $e');
//       if (!mounted) return;
//       setState(() {
//         // Jika geocoding gagal, set alamat ke lat/lng atau pesan error.
//         _currentAddress =
//             'Alamat tidak ditemukan. (Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)})';
//       });
//     }
//   }

//   void _updateMapToCurrentLocation() {
//     if (mapController != null && _currentLat != null && _currentLng != null) {
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(LatLng(_currentLat!, _currentLng!), 17.0),
//       );
//     }
//   }

//   Future<void> _fetchTodayAttendanceStatus() async {
//     if (!mounted) return;
//     setState(() {
//       _isLoadingApiAction = true;
//     });
//     try {
//       final AttendanceRecord? status =
//           await _attendanceService.getTodayAttendance();
//       if (!mounted) return;
//       setState(() {
//         _todayAttendance = status;
//       });
//     } catch (e) {
//       debugPrint('Error fetching today attendance status: $e');
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = e.toString().replaceFirst('Exception: ', '');
//       });
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isLoadingApiAction = false;
//       });
//     }
//   }

//   void _performCheckIn({required String status}) async {
//     // PERBAIKI INI: Hapus _currentAddress == 'Mendapatkan lokasi...' dari validasi awal.
//     // Hanya butuh lat/lng untuk absen
//     if (_currentLat == null || _currentLng == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Koordinat lokasi belum ditemukan. Mohon tunggu sesaat.',
//           ),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       await _initializePageData(); // Coba inisialisasi ulang
//       return;
//     }

//     String? alasanIzin;
//     if (status == 'izin') {
//       alasanIzin = await _showIzinReasonDialog();
//       if (alasanIzin == null || alasanIzin.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Absensi izin dibatalkan atau alasan tidak diisi.'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//         return;
//       }
//     }

//     if (!mounted) return;
//     setState(() {
//       _isLoadingApiAction = true;
//     });
//     try {
//       final response = await _attendanceService.checkIn(
//         status: status,
//         alasanIzin: alasanIzin,
//       );
//       if (!mounted) return;
//       setState(() {
//         _todayAttendance = response.data;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(response.message),
//           backgroundColor: Colors.green,
//         ),
//       );
//       _fetchTodayAttendanceStatus();
//     } catch (e) {
//       debugPrint('Check-in failed: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Check-in gagal: ${e.toString().replaceFirst('Exception: ', '')}',
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isLoadingApiAction = false;
//       });
//     }
//   }

//   Future<String?> _showIzinReasonDialog() async {
//     TextEditingController reasonController = TextEditingController();
//     return showDialog<String>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Alasan Izin'),
//           content: TextField(
//             controller: reasonController,
//             decoration: const InputDecoration(
//               hintText: 'Masukkan alasan izin Anda',
//             ),
//             maxLines: 3,
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Batal'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             ElevatedButton(
//               child: const Text('Kirim'),
//               onPressed: () {
//                 Navigator.of(context).pop(reasonController.text);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//  void _performCheckOut() async {
//     // Validasi awal: Pastikan lokasi sudah didapat sebelum mengirim permintaan
//     if (_currentLat == null || _currentLng == null || _currentAddress == 'Mendapatkan lokasi...') {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Lokasi belum ditemukan. Mohon tunggu sesaat.'), backgroundColor: Colors.orange),
//         );
//         await _initializePageData(); // Coba inisialisasi ulang jika lokasi belum siap
//         return;
//     }

//     if (!mounted) return; // Pastikan widget masih ada
//     setState(() {
//         _isLoadingApiAction = true; // Tampilkan indikator loading pada tombol
//     });

//     try {
//         // Panggil metode checkOut di AttendanceService
//         final response = await _attendanceService.checkOut();

//         if (!mounted) return; // Pastikan widget masih ada setelah async call
//         setState(() {
//             _todayAttendance = response.data; // Perbarui record absensi hari ini dengan data respons (sekarang check_out_time sudah terisi)
//         });

//         // Tampilkan pesan sukses
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(response.message), backgroundColor: Colors.green),
//         );

//         // Perbarui status absensi hari ini dan riwayat (jika ada) di UI
//         _fetchTodayAttendanceStatus(); // Memperbarui UI tombol
//         // _fetchAttendanceHistory(); // Jika Anda memiliki riwayat absensi yang ingin di-refresh

//     } catch (e) {
//         // Tangani error jika check out gagal
//         debugPrint('Check-out failed: $e');
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Check-out gagal: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.red),
//         );
//     } finally {
//         if (!mounted) return;
//         setState(() {
//             _isLoadingApiAction = false; // Sembunyikan indikator loading
//         });
//     }
// }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final now = DateTime.now();

//     // Variabel yang sudah diformat untuk langsung digunakan
//     final String formattedTime = DateFormat('hh:mm a').format(now);
//     final String formattedDate = DateFormat(
//       'EEE, dd MMMM yyyy',
//     ).format(now); // yyyy ditambahkan langsung

//     // --- Logika Penentuan Status dan Visibilitas Tombol ---
//     String currentStatusMessage = '';
//     bool showCheckInAsPresentButton = false;
//     bool showCheckInAsLeaveButton = false;
//     bool showCheckOutButton =
//         _todayAttendance != null && // Ada record absensi hari ini
//         _todayAttendance?.checkOutTime == null && // Belum check-out
//         _todayAttendance?.status == 'masuk'; // Status harus 'masuk'

//     final bool buttonsDisabled =
//         _isLoadingApiAction || _isFetchingInitialData || _errorMessage != null;

//     if (_isFetchingInitialData) {
//       currentStatusMessage = 'Memuat lokasi & status absensi...';
//     } else if (_errorMessage != null) {
//       currentStatusMessage = 'Error: $_errorMessage';
//     } else if (_todayAttendance == null) {
//       currentStatusMessage = 'Anda belum absen hari ini.';
//       showCheckInAsPresentButton = true;
//       showCheckInAsLeaveButton = true;
//     } else if (_todayAttendance?.status == 'masuk') {
//       if (_todayAttendance?.checkOutTime == null) {
//         currentStatusMessage =
//             'Anda sudah Check In pada ${DateFormat('HH:mm a').format(_todayAttendance!.checkInTime!)}.';
//         showCheckOutButton = true;
//       } else {
//         currentStatusMessage =
//             'Anda sudah Check In & Check Out pada ${DateFormat('HH:mm a').format(_todayAttendance!.checkOutTime!)}.';
//       }
//     } else if (_todayAttendance?.status == 'izin') {
//       currentStatusMessage =
//           'Anda sudah Izin hari ini karena ${_todayAttendance!.alasanIzin ?? 'alasan tidak dicatat'}.';
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // Peta Google Maps
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target:
//                   _currentLat != null && _currentLng != null
//                       ? LatLng(_currentLat!, _currentLng!)
//                       : const LatLng(
//                         -6.2088,
//                         106.8456,
//                       ), // Default Jakarta jika belum ada lokasi
//               zoom: 15.0,
//             ),
//             markers: _markers,
//             myLocationButtonEnabled: true,
//             myLocationEnabled: true,
//             zoomControlsEnabled: false,
//             compassEnabled: true,
//           ),

//           // Card "Check in" di atas peta
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: screenHeight * 0.6,
//               decoration: BoxDecoration(
//                 color: AppColors.loginCardColor,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 10,
//                     offset: const Offset(0, -5),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(25.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Absensi Hari Ini',
//                       style: Theme.of(
//                         context,
//                       ).textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textDark,
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     // Your Location Section
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Icon(
//                           Icons.location_on,
//                           color: Colors.black,
//                           size: 28,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Lokasi Anda',
//                                 style: Theme.of(
//                                   context,
//                                 ).textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.textDark,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               _isFetchingInitialData &&
//                                       _currentAddress == 'Mendapatkan lokasi...'
//                                   ? const CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   )
//                                   : Text(
//                                     _currentAddress,
//                                     style: Theme.of(
//                                       context,
//                                     ).textTheme.bodyMedium?.copyWith(
//                                       color: Colors.grey[700],
//                                       height: 1.5,
//                                     ),
//                                   ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 25),
//                     // Note (Optional) Section
//                     const Divider(height: 1, thickness: 1, color: Colors.grey),
//                     const SizedBox(height: 15),
//                     Row(
//                       children: [
//                         const Icon(Icons.notes, color: Colors.black, size: 24),
//                         const SizedBox(width: 10),
//                         Text(
//                           'Catatan (Opsional)',
//                           style: Theme.of(
//                             context,
//                           ).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textDark,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: _noteController,
//                       decoration: InputDecoration(
//                         hintText: 'Tambahkan catatan jika perlu...',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 15,
//                           vertical: 10,
//                         ),
//                       ),
//                       maxLines: 2,
//                     ),
//                     const SizedBox(height: 25),
//                     // Status Absensi Hari Ini
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child:
//                           _isFetchingInitialData
//                               ? const CircularProgressIndicator(strokeWidth: 2)
//                               : Text(
//                                 'Status Absensi : $currentStatusMessage',
//                                 style: Theme.of(
//                                   context,
//                                 ).textTheme.titleMedium?.copyWith(
//                                   color:
//                                       (currentStatusMessage.contains('Error') ||
//                                               currentStatusMessage.contains(
//                                                 'ditolak',
//                                               ))
//                                           ? Colors.red
//                                           : (currentStatusMessage.contains(
//                                                 'Check In pada',
//                                               ) ||
//                                               currentStatusMessage.contains(
//                                                 'Izin hari ini',
//                                               ) ||
//                                               currentStatusMessage.contains(
//                                                 'Check Out pada',
//                                               ))
//                                           ? Colors.green
//                                           : AppColors.textDark,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                     ),
//                     const Spacer(),
//                     // Tombol Aksi (Check In / Check Out)
//                     SizedBox(
//                       width: double.infinity,
//                       child:
//                           _isLoadingApiAction
//                               ? const Center(child: CircularProgressIndicator())
//                               : Column(
//                                 children: [
//                                   if (showCheckInAsPresentButton)
//                                     ElevatedButton(
//                                       onPressed:
//                                           buttonsDisabled
//                                               ? null
//                                               : () => _performCheckIn(
//                                                 status: 'masuk',
//                                               ),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor:
//                                             AppColors.loginButtonColor,
//                                         foregroundColor: AppColors.textLight,
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 15,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             15,
//                                           ),
//                                         ),
//                                       ),
//                                       child: const Text(
//                                         'Check In (Masuk)',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   if (showCheckInAsPresentButton &&
//                                       showCheckInAsLeaveButton)
//                                     const SizedBox(height: 10),
//                                   if (showCheckInAsLeaveButton)
//                                     ElevatedButton(
//                                       onPressed:
//                                           buttonsDisabled
//                                               ? null
//                                               : () => _performCheckIn(
//                                                 status: 'izin',
//                                               ),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor:
//                                             AppColors.loginAccentColor,
//                                         foregroundColor: AppColors.textDark,
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 15,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             15,
//                                           ),
//                                         ),
//                                       ),
//                                       child: const Text(
//                                         'Check In (Izin)',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   if (showCheckOutButton)
//                                     ElevatedButton(
//                                       onPressed:
//                                           buttonsDisabled
//                                               ? null
//                                               : _performCheckOut,
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor:
//                                             AppColors.loginButtonColor,
//                                         foregroundColor: AppColors.textLight,
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 15,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             15,
//                                           ),
//                                         ),
//                                       ),
//                                       child: const Text(
//                                         'Check Out',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   // Menampilkan status akhir jika tidak ada tombol yang aktif
//                                   if (!showCheckInAsPresentButton &&
//                                       !showCheckInAsLeaveButton &&
//                                       !showCheckOutButton &&
//                                       !buttonsDisabled)
//                                     Text(
//                                       'Status terakhir: $currentStatusMessage',
//                                       textAlign: TextAlign.center,
//                                       style:
//                                           Theme.of(
//                                             context,
//                                           ).textTheme.bodyMedium,
//                                     ),
//                                 ],
//                               ),
//                     ),
//                   ],   
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

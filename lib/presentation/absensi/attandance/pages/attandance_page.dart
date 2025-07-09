// File: AttandancePage.dart

import 'package:absensi_maps/presentation/absensi/attandance/models/attandance_model.dart';
import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_service.dart'
    show AttendanceService;
import 'package:absensi_maps/utils/app_colors.dart' show AppColors;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Untuk mendapatkan lokasi
import 'package:geocoding/geocoding.dart'; // Untuk mendapatkan alamat dari lat/lng
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class AttandancePage extends StatefulWidget {
  const AttandancePage({super.key});

  @override
  State<AttandancePage> createState() => _AttandancePageState();
}

class _AttandancePageState extends State<AttandancePage> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};

  final TextEditingController _noteController = TextEditingController();

  AttendanceRecord? _todayAttendance;
  String _currentAddress =
      'Mendapatkan lokasi...'; // Alamat yang didapat dari GPS
  double? _currentLat;
  double? _currentLng;

  bool _isFetchingInitialData = true;
  bool _isLoadingApiAction = false;
  String? _errorMessage;

  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _initializePageData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentLat != null && _currentLng != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_currentLat!, _currentLng!), 17.0),
      );
    }
  }

  Future<void> _initializePageData() async {
    setState(() {
      _isFetchingInitialData = true;
      _errorMessage = null;
    });

    try {
      final Position position = await _getCurrentLocation();
      _currentLat = position.latitude;
      _currentLng = position.longitude;

      _updateMapToCurrentLocation();
      await _getAddressFromLatLng(position); // Dapatkan alamat di sini
      await _fetchTodayAttendanceStatus();
    } catch (e) {
      debugPrint('Error initializing AttandancePage: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _currentAddress =
            'Alamat tidak ditemukan.'; // Set alamat ke pesan error juga
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isFetchingInitialData = false;
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        'Layanan lokasi tidak diaktifkan. Mohon aktifkan GPS Anda.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak. Mohon izinkan akses lokasi.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Izin lokasi ditolak secara permanen. Mohon ubah di pengaturan aplikasi.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Mengkonversi lat/lng menjadi alamat (reverse geocoding)
  Future<void> _getAddressFromLatLng(Position position) async {
    setState(() {
      _currentAddress = 'Mendapatkan lokasi...'; // Set status loading alamat
    });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        // localeIdentifier: 'id_ID', // Opsional: Untuk bahasa Indonesia
      );
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // COBA PRIORITASKAN ALAMAT YANG LEBIH SEDERHANA (KOTA/DISTRIK)
          String simplifiedAddress =
              place.locality ?? place.subLocality ?? place.street ?? '';

          // Jika alamat sederhana masih kosong, baru gunakan alamat lengkap.
          _currentAddress =
              simplifiedAddress.isNotEmpty
                  ? simplifiedAddress
                  : "${place.street ?? ''}, ${place.subLocality ?? ''}, "
                      "${place.locality ?? ''}, ${place.administrativeArea ?? ''} ${place.postalCode ?? ''}, ${place.country ?? ''}";

          // OPSIONAL: Jika alamat lengkap masih sering ditolak, pangkas menjadi maksimal X karakter
          // if (_currentAddress.length > 100) { // Contoh: pangkas ke 100 karakter
          //   _currentAddress = _currentAddress.substring(0, 97) + '...';
          // }

          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: InfoWindow(title: _currentAddress),
            ),
          );
        });
      } else {
        setState(() {
          _currentAddress = ''; // Alamat kosong jika tidak ada placemarks
        });
      }
    } catch (e) {
      debugPrint('Error getting address from location: $e');
      if (!mounted) return;
      setState(() {
        _currentAddress = ''; // Alamat kosong jika geocoding gagal
      });
    }
  }

  void _updateMapToCurrentLocation() {
    if (mapController != null && _currentLat != null && _currentLng != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_currentLat!, _currentLng!), 17.0),
      );
    }
  }

  Future<void> _fetchTodayAttendanceStatus() async {
    if (!mounted) return;
    setState(() {
      _isLoadingApiAction = true;
    });
    try {
      final AttendanceRecord? status =
          await _attendanceService.getTodayAttendance();
      if (!mounted) return;
      setState(() {
        _todayAttendance = status;
      });
    } catch (e) {
      debugPrint('Error fetching today attendance status: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingApiAction = false;
      });
    }
  }

  void _performCheckIn({required String status}) async {
    // Validasi: Pastikan koordinat lokasi sudah didapat
    if (_currentLat == null || _currentLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Koordinat lokasi belum ditemukan. Mohon tunggu sesaat.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      await _initializePageData(); // Coba inisialisasi ulang
      return;
    }
    // VALIDASI KRITIS: Pastikan _currentAddress tidak kosong
    if (_currentAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alamat lokasi tidak tersedia. Mohon tunggu sesaat atau periksa koneksi internet.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? alasanIzin;
    if (status == 'izin') {
      alasanIzin = await _showIzinReasonDialog();
      if (alasanIzin == null || alasanIzin.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Absensi izin dibatalkan atau alasan tidak diisi.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoadingApiAction = true;
    });
    try {
      final response = await _attendanceService.checkIn(
        status: status,
        alasanIzin: alasanIzin,
        checkInAddress: _currentAddress, // Teruskan alamat yang sudah didapat
      );
      if (!mounted) return;
      setState(() {
        _todayAttendance = response.data;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      _fetchTodayAttendanceStatus();
    } catch (e) {
      debugPrint('Check-in failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-in gagal: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingApiAction = false;
      });
    }
  }

  Future<String?> _showIzinReasonDialog() async {
    TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alasan Izin'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Masukkan alasan izin Anda',
            ),
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

  void _performCheckOut() async {
    if (_currentLat == null || _currentLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Koordinat lokasi belum ditemukan. Mohon tunggu sesaat.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      await _initializePageData(); // Coba inisialisasi ulang
      return;
    }
    // VALIDASI KRITIS: Pastikan _currentAddress tidak kosong
    if (_currentAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alamat lokasi tidak tersedia. Mohon tunggu sesaat atau periksa koneksi.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoadingApiAction = true;
    });
    try {
      final response = await _attendanceService.checkOut(
        checkOutAddress: _currentAddress, // Teruskan alamat yang sudah didapat
      );
      if (!mounted) return;
      setState(() {
        _todayAttendance = response.data;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      _fetchTodayAttendanceStatus();
    } catch (e) {
      debugPrint('Check-out failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-out gagal: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingApiAction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final now = DateTime.now();
    final String formattedTime = DateFormat('hh:mm a').format(now);
    final String formattedDate = DateFormat('EEE, dd MMMM ').format(now);

    String currentStatusMessage = '';
    bool showCheckInAsPresentButton = false;
    bool showCheckInAsLeaveButton = false;
    bool showCheckOutButton = false;

    final bool buttonsDisabled =
        _isLoadingApiAction || _isFetchingInitialData || _errorMessage != null;

    if (_isFetchingInitialData) {
      currentStatusMessage = 'Memuat lokasi & status absensi...';
    } else if (_errorMessage != null) {
      currentStatusMessage = 'Error: $_errorMessage';
    } else if (_todayAttendance == null) {
      currentStatusMessage = 'Anda belum absen hari ini.';
      showCheckInAsPresentButton = true;
      showCheckInAsLeaveButton = true;
    } else if (_todayAttendance?.status == 'masuk') {
      if (_todayAttendance?.checkOutTime == null) {
        currentStatusMessage =
            'Anda sudah Check In pada ${DateFormat('HH:mm a').format(_todayAttendance!.checkInTime!)}.';
        showCheckOutButton = true;
      } else {
        currentStatusMessage =
            'Anda sudah Check In & Check Out pada ${DateFormat('HH:mm a').format(_todayAttendance!.checkOutTime!)}.';
      }
    } else if (_todayAttendance?.status == 'izin') {
      currentStatusMessage =
          'Anda sudah Izin hari ini karena ${_todayAttendance!.alasanIzin ?? 'alasan tidak dicatat'}.';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Peta Google Maps
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target:
                  _currentLat != null && _currentLng != null
                      ? LatLng(_currentLat!, _currentLng!)
                      : const LatLng(-6.2088, 106.8456),
              zoom: 15.0,
            ),
            markers: _markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

          // Card "Check in" di atas peta
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: screenHeight * 0.35,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.loginCardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB((255 * 0.2).round(), 0, 0, 0),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Absensi Hari Ini',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Your Location Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.black,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lokasi Anda',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 5),
                              _isFetchingInitialData &&
                                      _currentAddress == 'Mendapatkan lokasi...'
                                  ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )
                                  : Text(
                                    _currentAddress,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Note (Optional) Section
                    const Divider(height: 1, thickness: 1, color: Colors.grey),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.notes, color: Colors.black, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Catatan (Opsional)',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan jika perlu...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 25),
                    // Status Absensi Hari Ini
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                          _isFetchingInitialData
                              ? const CircularProgressIndicator(strokeWidth: 2)
                              : Text(
                                'Status Absensi : $currentStatusMessage',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color:
                                      (currentStatusMessage.contains('Error') ||
                                              currentStatusMessage.contains(
                                                'ditolak',
                                              ))
                                          ? Colors.red
                                          : (currentStatusMessage.contains(
                                                'Check In pada',
                                              ) ||
                                              currentStatusMessage.contains(
                                                'Izin hari ini',
                                              ) ||
                                              currentStatusMessage.contains(
                                                'Check Out pada',
                                              ))
                                          ? Colors.green
                                          : AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                    const SizedBox(height: 10),
                    // Tombol Aksi (Check In / Check Out)
                    SizedBox(
                      width: double.infinity,
                      child:
                          _isLoadingApiAction
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                children: [
                                  if (showCheckInAsPresentButton)
                                    ElevatedButton(
                                      onPressed:
                                          buttonsDisabled
                                              ? null
                                              : () => _performCheckIn(
                                                status: 'masuk',
                                              ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.loginButtonColor,
                                        foregroundColor: AppColors.textLight,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Check In (Masuk)',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (showCheckInAsPresentButton &&
                                      showCheckInAsLeaveButton)
                                    const SizedBox(height: 10),
                                  if (showCheckInAsLeaveButton)
                                    ElevatedButton(
                                      onPressed:
                                          buttonsDisabled
                                              ? null
                                              : () => _performCheckIn(
                                                status: 'izin',
                                              ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.loginAccentColor,
                                        foregroundColor: AppColors.textDark,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Check In (Izin)',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (showCheckOutButton)
                                    ElevatedButton(
                                      onPressed:
                                          buttonsDisabled
                                              ? null
                                              : _performCheckOut,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.loginButtonColor,
                                        foregroundColor: AppColors.textLight,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Check Out',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (!showCheckInAsPresentButton &&
                                      !showCheckInAsLeaveButton &&
                                      !showCheckOutButton &&
                                      !buttonsDisabled)
                                    Text(
                                      'Status terakhir: $currentStatusMessage',
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                ],
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

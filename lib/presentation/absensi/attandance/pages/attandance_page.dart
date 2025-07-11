// File: lib/presentation/absensi/attandance/pages/attandance_page.dart

import 'package:absensi_maps/models/attandance_model.dart';
import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_service.dart';
import 'package:absensi_maps/utils/app_colors.dart';
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

  Attendance? _todayAttendance;
  String _currentAddress = 'Mendapatkan lokasi...';
  double? _currentLat;
  double? _currentLng;

  bool _isFetchingInitialData = true;
  bool _isLoadingApiAction = false;
  String? _errorMessage;
  bool _isLocationPermissionsGrantedAndReady = false;

  final AttendanceService _attendanceService = AttendanceService();

  late Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    debugPrint('AttandancePage: initState terpanggil.');
    _initializePageData();
    _clockStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    mapController?.dispose();
    debugPrint('AttandancePage: dispose terpanggil.');
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    debugPrint('AttandancePage: MapController dibuat.');
    if (_currentLat != null && _currentLng != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_currentLat!, _currentLng!), 17.0),
      );
      debugPrint('AttandancePage: Kamera peta diupdate ke lokasi saat ini.');
    } else {
      debugPrint(
        'AttandancePage: Lokasi belum tersedia, tidak bisa update kamera.',
      );
    }
  }

  Future<void> _initializePageData() async {
    debugPrint('AttandancePage: _initializePageData dimulai.');
    if (!mounted) {
      debugPrint('AttandancePage: _initializePageData: Widget tidak mounted.');
      return;
    }
    setState(() {
      _isFetchingInitialData = true;
      _errorMessage = null;
      _isLocationPermissionsGrantedAndReady = false;
    });

    try {
      debugPrint('AttandancePage: Mencoba mendapatkan lokasi saat ini.');
      final Position position = await _getCurrentLocation();
      _currentLat = position.latitude;
      _currentLng = position.longitude;
      debugPrint(
        'AttandancePage: Lokasi didapat: Lat: $_currentLat, Lng: $_currentLng',
      );

      if (!mounted) return;
      setState(() {
        _isLocationPermissionsGrantedAndReady = true;
      });

      _updateMapToCurrentLocation();
      await _getAddressFromLatLng(position);
      debugPrint('AttandancePage: Alamat didapat: $_currentAddress');
      await _fetchTodayAttendanceStatus();
    } catch (e) {
      debugPrint('AttandancePage: Error di _initializePageData: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _currentAddress = 'Alamat tidak ditemukan.';
        _isLocationPermissionsGrantedAndReady = false;
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
      debugPrint('AttandancePage: _initializePageData selesai.');
    }
  }

  Future<Position> _getCurrentLocation() async {
    debugPrint('AttandancePage: _getCurrentLocation dimulai.');
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('AttandancePage: Layanan lokasi tidak diaktifkan.');
      return Future.error(
        'Layanan lokasi tidak diaktifkan. Mohon aktifkan GPS Anda.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('AttandancePage: Izin lokasi ditolak, meminta izin.');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('AttandancePage: Izin lokasi masih ditolak.');
        return Future.error('Izin lokasi ditolak. Mohon izinkan akses lokasi.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('AttandancePage: Izin lokasi ditolak secara permanen.');
      return Future.error(
        'Izin lokasi ditolak secara permanen. Mohon ubah di pengaturan aplikasi.',
      );
    }

    debugPrint('AttandancePage: Mendapatkan posisi GPS saat ini.');
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    debugPrint('AttandancePage: _getAddressFromLatLng dimulai.');
    setState(() {
      _currentAddress = 'Mendapatkan lokasi...';
    });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          String street = place.street ?? '';
          String subLocality = place.subLocality ?? '';
          String locality = place.locality ?? '';
          String subAdministrativeArea = place.subAdministrativeArea ?? '';
          String administrativeArea = place.administrativeArea ?? '';

          List<String> addressParts = [];
          if (street.isNotEmpty) addressParts.add(street);
          if (subLocality.isNotEmpty && !street.contains(subLocality)) {
            addressParts.add(subLocality);
          }
          if (subAdministrativeArea.isNotEmpty &&
              !subLocality.contains(subAdministrativeArea)) {
            addressParts.add(subAdministrativeArea);
          }
          if (locality.isNotEmpty &&
              !subAdministrativeArea.contains(locality)) {
            addressParts.add(locality);
          }
          if (administrativeArea.isNotEmpty &&
              !locality.contains(administrativeArea)) {
            addressParts.add(administrativeArea);
          }

          _currentAddress = addressParts.join(', ');
          if (_currentAddress.isEmpty) {
            _currentAddress = 'Alamat tidak diketahui.';
          }

          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: InfoWindow(title: _currentAddress),
            ),
          );
        });
        debugPrint(
          'AttandancePage: Alamat dari LatLng berhasil: $_currentAddress',
        );
      } else {
        setState(() {
          _currentAddress = 'Alamat tidak ditemukan.';
        });
        debugPrint('AttandancePage: Tidak ada placemarks ditemukan.');
      }
    } catch (e) {
      debugPrint('AttandancePage: Error mendapatkan alamat dari lokasi: $e');
      if (!mounted) return;
      setState(() {
        _currentAddress = 'Gagal mendapatkan alamat.';
      });
    }
  }

  void _updateMapToCurrentLocation() {
    debugPrint('AttandancePage: _updateMapToCurrentLocation dimulai.');
    if (mapController != null && _currentLat != null && _currentLng != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_currentLat!, _currentLng!), 17.0),
      );
      debugPrint(
        'AttandancePage: Peta diupdate ke lokasi: $_currentLat, $_currentLng',
      );
    } else {
      debugPrint(
        'AttandancePage: Tidak bisa update peta, lokasi atau mapController null.',
      );
    }
  }

  Future<void> _fetchTodayAttendanceStatus() async {
    debugPrint('AttandancePage: _fetchTodayAttendanceStatus dimulai.');
    if (!mounted) return;
    setState(() {
      _isLoadingApiAction = true;
    });
    try {
      final AttendanceApiResponse response =
          await _attendanceService.getTodayAttendance();
      if (!mounted) return;
      setState(() {
        _todayAttendance = response.data;
        _errorMessage = null;
      });
      debugPrint(
        'AttandancePage: Status absensi hari ini berhasil diambil: ${_todayAttendance?.status}',
      );
    } catch (e) {
      debugPrint('AttandancePage: Error fetching today attendance status: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingApiAction = false;
      });
      debugPrint('AttandancePage: _fetchTodayAttendanceStatus selesai.');
    }
  }

  void _showAttendanceActionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<Widget> options = [];

        if (_todayAttendance == null || _todayAttendance?.status == 'pulang') {
          options.add(
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Check In (Masuk)'),
              onTap: () {
                Navigator.of(context).pop();
                _performCheckIn();
              },
            ),
          );
          options.add(
            ListTile(
              leading: const Icon(Icons.event_busy),
              title: const Text('Ajukan Izin/Cuti'),
              onTap: () {
                Navigator.of(context).pop();
                _performCheckIn(isIzin: true);
              },
            ),
          );
        } else if (_todayAttendance?.status == 'masuk' &&
            _todayAttendance?.checkOut == null) {
          options.add(
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Check Out'),
              onTap: () {
                Navigator.of(context).pop();
                _performCheckOut();
              },
            ),
          );
        } else {
          options.add(
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(
                'Status Hari Ini: ${_todayAttendance?.status ?? 'Memuat...'}',
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          );
        }

        return AlertDialog(
          title: const Text('Pilih Aksi Absensi'),
          content: Column(mainAxisSize: MainAxisSize.min, children: options),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _performCheckIn({bool isIzin = false}) async {
    debugPrint('AttandancePage: _performCheckIn dimulai. isIzin: $isIzin');
    if (_currentLat == null || _currentLng == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Koordinat lokasi belum ditemukan. Mohon tunggu sesaat.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_currentAddress.isEmpty ||
        _currentAddress.contains('Mendapatkan lokasi')) {
      if (!mounted) return;
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
    if (isIzin) {
      alasanIzin = await _showIzinReasonDialog();
      if (alasanIzin == null || alasanIzin.isEmpty) {
        if (!mounted) return;
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
      AttendanceApiResponse response;
      if (isIzin) {
        response = await _attendanceService.submitIzin(
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          reason: alasanIzin!,
        );
      } else {
        response = await _attendanceService.checkIn(
          alasanIzin:
              _noteController.text.isNotEmpty ? _noteController.text : null,
          checkInAddress: _currentAddress,
          latitude: _currentLat!,
          longitude: _currentLng!,
        );
      }

      if (!mounted) return;
      setState(() {
        _todayAttendance = response.data;
        _noteController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      _fetchTodayAttendanceStatus();
    } catch (e) {
      debugPrint('AttandancePage: Aksi absensi gagal: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Aksi absensi gagal: ${e.toString().replaceFirst('Exception: ', '')}',
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alasan Izin'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Masukkan alasan izin Anda (wajib)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            ElevatedButton(
              child: const Text('Kirim'),
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alasan izin tidak boleh kosong.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else {
                  Navigator.of(context).pop(reasonController.text.trim());
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _performCheckOut() async {
    if (_currentLat == null || _currentLng == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Koordinat lokasi belum ditemukan. Mohon tunggu sesaat.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_currentAddress.isEmpty ||
        _currentAddress.contains('Mendapatkan lokasi')) {
      if (!mounted) return;
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
      final AttendanceApiResponse response = await _attendanceService.checkOut(
        checkOutAddress: _currentAddress,
        latitude: _currentLat!,
        longitude: _currentLng!,
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
    debugPrint('AttandancePage: build terpanggil.');
    final screenHeight = MediaQuery.of(context).size.height;

    String currentStatusMessage = '';
    bool showCheckInAsPresentButton = false;
    bool showCheckInAsLeaveButton = false;
    bool showCheckOutButton = false;

    final bool buttonsDisabled =
        _isLoadingApiAction || _isFetchingInitialData || _errorMessage != null;

    // Logic untuk menentukan status dan tombol yang ditampilkan
    if (_isFetchingInitialData) {
      currentStatusMessage = 'Memuat lokasi & status absensi...';
    } else if (_errorMessage != null) {
      currentStatusMessage = 'Error: $_errorMessage';
    } else if (_todayAttendance == null) {
      currentStatusMessage = 'Anda belum absen hari ini.';
      showCheckInAsPresentButton = true;
      showCheckInAsLeaveButton = true;
    } else if (_todayAttendance!.status == 'masuk') {
      if (_todayAttendance!.checkOut == null) {
        currentStatusMessage =
            'Anda sudah Check In pada ${_todayAttendance!.checkIn ?? 'N/A'}.';
        showCheckOutButton = true;
      } else {
        currentStatusMessage =
            'Anda sudah Check In & Check Out pada ${_todayAttendance!.checkOut ?? 'N/A'}.';
      }
    } else if (_todayAttendance!.status == 'izin') {
      currentStatusMessage =
          'Anda sudah Izin hari ini karena ${_todayAttendance!.reason ?? 'alasan tidak dicatat'}.';
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
                      : const LatLng(-6.2088, 106.8456), // Default ke Jakarta
              zoom: 15.0,
            ),
            markers: _markers,
            myLocationButtonEnabled: _isLocationPermissionsGrantedAndReady,
            myLocationEnabled: _isLocationPermissionsGrantedAndReady,
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
              // --- RefreshIndicator ditambahkan di sini ---
              child: RefreshIndicator(
                onRefresh:
                    _initializePageData, // Panggil metode untuk refresh semua data
                color: AppColors.loginButtonColor, // Warna indikator refresh
                backgroundColor: Colors.white, // Latar belakang indikator
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
                                        _currentAddress ==
                                            'Mendapatkan lokasi...'
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
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(
                            Icons.notes,
                            color: Colors.black,
                            size: 24,
                          ),
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
                                ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                )
                                : Text(
                                  'Status Absensi : $currentStatusMessage',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color:
                                        (currentStatusMessage.contains(
                                                  'Error',
                                                ) ||
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
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : Column(
                                  children: [
                                    if (showCheckInAsPresentButton)
                                      ElevatedButton(
                                        onPressed:
                                            buttonsDisabled
                                                ? null
                                                : () => _performCheckIn(),
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
                                                  isIzin: true,
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
          ),
        ],
      ),
    );
  }
}

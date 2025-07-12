// File: lib/presentation/absensi/attandance/pages/attandance_page.dart

import 'package:absensi_maps/models/attandance_model.dart'; // Model Attendance Anda
import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_api_service.dart';
import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_service.dart'; // Service Anda
import 'package:absensi_maps/utils/app_colors.dart'; // Colors Anda
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Untuk mendapatkan lokasi
import 'package:geocoding/geocoding.dart'; // Untuk mendapatkan alamat dari lat/lng
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu
import 'package:flutter/foundation.dart'; // Untuk debugPrint

// Pastikan Anda mengimpor AttendanceApiResponse jika itu adalah model terpisah
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

  bool _isFetchingInitialData =
      true; // Untuk loading data awal (lokasi, status absensi)
  bool _isLoadingApiAction =
      false; // Untuk loading saat melakukan check-in/out/izin
  String?
  _displayMessage; // Pesan yang ditampilkan di UI (bisa error atau info normal)
  bool _isLocationPermissionsGrantedAndReady = false;

  final AttendanceService _attendanceService = AttendanceService();

  late Stream<DateTime> _clockStream; // Untuk menampilkan jam real-time

  // --- Lokasi kantor (sesuaikan dengan koordinat kantor Anda) ---
  // Sesuaikan dengan lokasi kantor Anda yang sebenarnya!
  final LatLng _officePosition = const LatLng(
    -6.2300,
    106.8200,
  ); // Contoh: Lokasi di Bekasi
  final double _allowedRadius =
      50.0; // Radius toleransi (meter) dari kantor, contoh: 50 meter
  double _distanceFromOffice = 0.0; // Jarak dari lokasi pengguna ke kantor

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID'; // Set locale untuk DateFormat
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
    super.dispose();
  }

  // Dipanggil saat peta Google Maps dibuat
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    debugPrint('AttandancePage: MapController dibuat.');
    // Setelah peta dibuat, segera update kamera ke lokasi saat ini jika sudah ada
    _updateMapToCurrentLocation();
  }

  // --- FUNGSI INTI UNTUK MENGINISIALISASI DATA HALAMAN ---
  Future<void> _initializePageData() async {
    debugPrint('AttandancePage: _initializePageData dimulai.');
    if (!mounted) {
      debugPrint('AttandancePage: _initializePageData: Widget tidak mounted.');
      return;
    }
    setState(() {
      _isFetchingInitialData = true;
      _displayMessage = null; // Reset pesan
      _isLocationPermissionsGrantedAndReady = false;
      _currentAddress = 'Mendapatkan lokasi...';
      _currentLat = null; // Reset lat/lng
      _currentLng = null;
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

      // Hitung jarak dari kantor setelah mendapatkan lokasi pengguna
      _distanceFromOffice = Geolocator.distanceBetween(
        _currentLat!,
        _currentLng!,
        _officePosition.latitude,
        _officePosition.longitude,
      );
      debugPrint(
        'AttandancePage: Jarak dari kantor: $_distanceFromOffice meter',
      );

      await _fetchTodayAttendanceStatus(); // Memuat status absensi setelah lokasi didapat
    } catch (e) {
      debugPrint('AttandancePage: Error di _initializePageData: $e');
      if (!mounted) return;
      setState(() {
        _displayMessage = e.toString().replaceFirst('Exception: ', '');
        _currentAddress = 'Alamat tidak ditemukan / Izin lokasi diperlukan.';
        _isLocationPermissionsGrantedAndReady = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Inisialisasi: $_displayMessage'),
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

  // --- FUNGSI MENDAPATKAN LOKASI GPS DAN IZIN ---
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
      // Tambahkan timeout untuk mencegah loading tak terbatas
      // timeout: const Duration(seconds: 10),
    );
  }

  // --- FUNGSI MENDAPATKAN ALAMAT DARI KOORDINAT ---
  Future<void> _getAddressFromLatLng(Position position) async {
    debugPrint('AttandancePage: _getAddressFromLatLng dimulai.');
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        // localeIdentifier: 'id_ID', // Menambahkan locale untuk hasil yang lebih akurat
      );
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // Bangun alamat dari komponen-komponen yang tersedia
          List<String> addressParts =
              [
                    place.street ?? '',
                    place.subLocality ?? '', // Kelurahan/Desa
                    place.locality ?? '', // Kota/Kabupaten
                    place.subAdministrativeArea ?? '', // Kecamatan
                    place.administrativeArea ?? '', // Provinsi
                    place.country ?? '',
                  ]
                  .where((s) => s.isNotEmpty)
                  .toList(); // Filter bagian yang kosong

          _currentAddress = addressParts.join(', ');
          if (_currentAddress.isEmpty) {
            _currentAddress = 'Alamat tidak ditemukan.';
          }

          // Tambahkan marker untuk lokasi saat ini dan lokasi kantor
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: InfoWindow(
                title: 'Lokasi Anda',
                snippet: _currentAddress,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ), // Warna merah untuk pengguna
            ),
          );
          _markers.add(
            Marker(
              markerId: const MarkerId('officeLocation'),
              position: _officePosition,
              infoWindow: const InfoWindow(
                title: 'Lokasi Kantor',
                snippet: 'Silakan sesuaikan alamat kantor',
              ), // Sesuaikan
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ), // Warna biru untuk kantor
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

  // --- FUNGSI MENGUPDATE KAMERA PETA ---
  void _updateMapToCurrentLocation() {
    debugPrint('AttandancePage: _updateMapToCurrentLocation dimulai.');
    // Pastikan mapController sudah diinisialisasi
    if (mapController != null && _currentLat != null && _currentLng != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_currentLat!, _currentLng!), 17.0),
      );
      debugPrint(
        'AttandancePage: Kamera peta diupdate ke lokasi: $_currentLat, $_currentLng',
      );
    } else {
      debugPrint(
        'AttandancePage: Tidak bisa update peta, lokasi atau mapController null. Akan menggunakan default.',
      );
    }
  }

  // --- FUNGSI MENGAMBIL STATUS ABSENSI HARI INI DARI API ---
  Future<void> _fetchTodayAttendanceStatus() async {
    debugPrint('AttandancePage: _fetchTodayAttendanceStatus dimulai.');
    if (!mounted) return;
    setState(() {
      _isLoadingApiAction = true; // Menggunakan ini untuk indikator di bawah
      _displayMessage = null; // Reset pesan error dari API
    });
    try {
      final AttendanceApiResponse response =
          await _attendanceService.getTodayAttendance();
      if (!mounted) return;

      setState(() {
        _todayAttendance = response.data; // Ini bisa null jika tidak ada data
        // Jika data null, tampilkan pesan informatif, bukan error
        if (_todayAttendance == null) {
          _displayMessage = response.message ?? 'Anda belum absen hari ini.';
        } else {
          // Jika ada data, tampilkan pesan sukses dari API atau pesan default
          _displayMessage = response.message;
        }
      });
      debugPrint(
        'AttandancePage: Status absensi hari ini berhasil diambil: ${_todayAttendance?.status ?? "Belum Absen"}',
      );
    } catch (e) {
      debugPrint('AttandancePage: Error fetching today attendance status: $e');
      if (!mounted) return;
      setState(() {
        _displayMessage = e.toString().replaceFirst('Exception: ', '');
      });
      // Tampilkan snackbar untuk error yang sebenarnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat status absensi: $_displayMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingApiAction = false;
      });
      debugPrint('AttandancePage: _fetchTodayAttendanceStatus selesai.');
    }
  }

  // --- FUNGSI UNTUK MENAMPILKAN BOTTOM SHEET OPSI AKSI ABSENSI ---
  void _showAttendanceActionDialog() {
    // Jangan tampilkan dialog jika sedang loading
    if (_isFetchingInitialData || _isLoadingApiAction) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Untuk sudut melengkung
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.loginCardColor, // Menggunakan warna dari AppColors
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Handle bar di atas bottom sheet
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                "Pilih Aksi Absensi",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              // Opsi Check In atau Izin (jika belum absen/sudah pulang)
              if (_todayAttendance == null ||
                  _todayAttendance?.checkOut != null) ...[
                ListTile(
                  leading: const Icon(
                    Icons.login,
                    color: AppColors.loginButtonColor,
                  ),
                  title: const Text('Check In (Masuk)'),
                  onTap: () {
                    Navigator.pop(context); // Tutup bottom sheet
                    _confirmCheckIn(); // Panggil konfirmasi check-in
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_busy, color: Colors.orange),
                  title: const Text('Ajukan Izin / Sakit'),
                  onTap: () {
                    Navigator.pop(context); // Tutup bottom sheet
                    _showIzinReasonDialog(); // Panggil dialog izin
                  },
                ),
              ],
              // Opsi Check Out (jika sudah check-in dan belum check-out)
              if (_todayAttendance?.status == 'masuk' &&
                  _todayAttendance?.checkOut == null)
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: AppColors.loginButtonColor,
                  ),
                  title: const Text('Check Out'),
                  onTap: () {
                    Navigator.pop(context); // Tutup bottom sheet
                    _confirmCheckOut(); // Panggil konfirmasi check-out
                  },
                ),
              // Jika tidak ada opsi (sudah izin atau sudah check-in/check-out penuh)
              if (_todayAttendance?.status == 'izin' ||
                  (_todayAttendance?.checkIn != null &&
                      _todayAttendance?.checkOut != null))
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.grey),
                  title: Text(
                    _todayAttendance?.status == 'izin'
                        ? 'Status Hari Ini: Izin'
                        : 'Status Hari Ini: Sudah Check In & Check Out',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Tutup bottom sheet
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // --- KONFIRMASI CHECK IN ---
  void _confirmCheckIn() {
    // Pastikan lokasi sudah ada sebelum konfirmasi
    if (_currentLat == null ||
        _currentLng == null ||
        _currentAddress.isEmpty ||
        _currentAddress.contains('Mendapatkan lokasi')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum siap. Mohon tunggu sesaat.'),
          backgroundColor: Colors.orange,
        ),
      );
      _initializePageData(); // Coba muat ulang lokasi
      return;
    }

    // Logika jarak: Memblokir jika di luar radius
    if (_distanceFromOffice > _allowedRadius) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak bisa Check In. Anda berada di luar radius ${_allowedRadius.toStringAsFixed(0)} meter dari kantor. Jarak Anda: ${_distanceFromOffice.toStringAsFixed(0)} meter.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; // Batalkan aksi jika di luar radius
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Check In'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anda akan melakukan Check In pada lokasi saat ini:',
                ),
                const SizedBox(height: 8),
                Text('Alamat: $_currentAddress'),
                Text(
                  'Jarak dari kantor: ${_distanceFromOffice.toStringAsFixed(0)} meter',
                ),
                if (_noteController.text.isNotEmpty)
                  Text('Catatan: ${_noteController.text}'),
                const SizedBox(height: 10),
                const Text('Pastikan lokasi sudah benar.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog konfirmasi
                  _performCheckIn(isIzin: false); // Lanjutkan dengan check-in
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loginButtonColor,
                ),
                child: const Text('Check In Sekarang'),
              ),
            ],
          ),
    );
  }

  // --- KONFIRMASI CHECK OUT ---
  void _confirmCheckOut() {
    // Pastikan lokasi sudah ada sebelum konfirmasi
    if (_currentLat == null ||
        _currentLng == null ||
        _currentAddress.isEmpty ||
        _currentAddress.contains('Mendapatkan lokasi')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum siap. Mohon tunggu sesaat.'),
          backgroundColor: Colors.orange,
        ),
      );
      _initializePageData(); // Coba muat ulang lokasi
      return;
    }

    // Logika jarak: Memblokir jika di luar radius (untuk konsistensi)
    if (_distanceFromOffice > _allowedRadius) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak bisa Check Out. Anda berada di luar radius ${_allowedRadius.toStringAsFixed(0)} meter dari kantor. Jarak Anda: ${_distanceFromOffice.toStringAsFixed(0)} meter.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; // Batalkan aksi jika di luar radius
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Check Out'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anda akan melakukan Check Out dari lokasi saat ini:',
                ),
                const SizedBox(height: 8),
                Text('Alamat: $_currentAddress'),
                Text(
                  'Jarak dari kantor: ${_distanceFromOffice.toStringAsFixed(0)} meter',
                ),
                if (_noteController.text.isNotEmpty)
                  Text('Catatan: ${_noteController.text}'),
                const SizedBox(height: 10),
                const Text('Pastikan lokasi sudah benar.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog konfirmasi
                  _performCheckOut(); // Lanjutkan dengan check-out
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loginButtonColor,
                ),
                child: const Text('Check Out Sekarang'),
              ),
            ],
          ),
    );
  }

  // --- FUNGSI MELAKUKAN CHECK IN / SUBMIT IZIN KE API ---
  void _performCheckIn({bool isIzin = false}) async {
    debugPrint('AttandancePage: _performCheckIn dimulai. isIzin: $isIzin');
    // Validasi lokasi dan catatan untuk izin akan dilakukan di _showIzinReasonDialog
    // Validasi lokasi dan radius untuk check-in akan dilakukan di _confirmCheckIn

    if (!mounted) return;
    setState(() {
      _isLoadingApiAction = true; // Tampilkan loading untuk aksi API
    });
    try {
      AttendanceApiResponse response;
      if (isIzin) {
        // Asumsi _showIzinReasonDialog sudah dijalankan dan _noteController berisi alasan
        // API submitIzin hanya menerima tanggal dan alasan, tidak perlu lokasi
        response = await _attendanceService.submitIzin(
          date: DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.now()), // Untuk izin hari ini
          reason:
              _noteController.text.isNotEmpty
                  ? _noteController.text
                  : "Tidak ada alasan", // Gunakan catatan sebagai alasan
        );
      } else {
        response = await _attendanceService.checkIn(
          latitude: _currentLat!,
          longitude: _currentLng!,
          checkInAddress: _currentAddress,
          alasanIzin:
              _noteController.text.isNotEmpty
                  ? _noteController.text
                  : null, // Catatan opsional
        );
      }

      if (!mounted) return;
      setState(() {
        _todayAttendance =
            response.data; // Update status absensi hari ini dari respons API
        _noteController.clear(); // Bersihkan catatan
        _displayMessage = response.message; // Tampilkan pesan sukses dari API
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      await _fetchTodayAttendanceStatus(); // Refresh status untuk memastikan UI terupdate
    } catch (e) {
      debugPrint('AttandancePage: Aksi absensi gagal: $e');
      if (!mounted) return;
      setState(() {
        _displayMessage = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aksi absensi gagal: $_displayMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingApiAction = false;
      });
      debugPrint('AttandancePage: _performCheckIn (atau Izin) selesai.');
    }
  }

  // --- FUNGSI MENAMPILKAN DIALOG ALASAN IZIN (Sebelum memanggil _performCheckIn dengan isIzin=true) ---
  Future<void> _showIzinReasonDialog() async {
    _noteController
        .clear(); // Pastikan _noteController bersih untuk input alasan

    final String? alasanIzin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Alasan Izin / Sakit'),
          content: TextField(
            controller: _noteController, // Menggunakan _noteController
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
                Navigator.of(
                  dialogContext,
                ).pop(null); // Mengembalikan null jika batal
              },
            ),
            ElevatedButton(
              child: const Text('Kirim'),
              onPressed: () {
                if (_noteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Alasan izin tidak boleh kosong.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else {
                  Navigator.of(
                    dialogContext,
                  ).pop(_noteController.text.trim()); // Mengembalikan alasan
                }
              },
            ),
          ],
        );
      },
    );

    // Jika pengguna memberikan alasan, lanjutkan pengajuan izin
    if (alasanIzin != null && alasanIzin.isNotEmpty) {
      // _noteController sudah berisi alasan, jadi langsung panggil performCheckIn
      _performCheckIn(isIzin: true);
    } else {
      // Jika batal atau alasan kosong, tampilkan pesan
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi izin dibatalkan atau alasan tidak diisi.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // --- FUNGSI MELAKUKAN CHECK OUT KE API ---
  void _performCheckOut() async {
    debugPrint('AttandancePage: _performCheckOut dimulai.');
    // Validasi lokasi dan radius sudah dilakukan di _confirmCheckOut

    if (!mounted) return;
    setState(() {
      _isLoadingApiAction = true; // Tampilkan loading untuk aksi API
    });
    try {
      final AttendanceApiResponse response = await _attendanceService.checkOut(
        latitude: _currentLat!,
        longitude: _currentLng!,
        checkOutAddress: _currentAddress,
      );
      if (!mounted) return;
      setState(() {
        _todayAttendance =
            response.data; // Update status absensi hari ini dari respons API
        _noteController.clear(); // Bersihkan catatan
        _displayMessage = response.message; // Tampilkan pesan sukses dari API
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      await _fetchTodayAttendanceStatus(); // Refresh status untuk memastikan UI terupdate
    } catch (e) {
      debugPrint('AttandancePage: Check-out gagal: $e');
      if (!mounted) return;
      setState(() {
        _displayMessage = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-out gagal: $_displayMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingApiAction = false;
      });
      debugPrint('AttandancePage: _performCheckOut selesai.');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AttandancePage: build terpanggil.');
    final screenHeight = MediaQuery.of(context).size.height;

    // Logika untuk menentukan pesan status dan ketersediaan tombol
    String currentStatusText =
        ''; // Pesan utama yang tampil di bagian "Status Absensi"
    String actionButtonText = ''; // Teks pada tombol aksi utama
    bool showActionButton = true; // Kontrol visibilitas tombol aksi

    // Status untuk menonaktifkan interaksi (tombol, textfield)
    final bool interactionDisabled =
        _isLoadingApiAction || _isFetchingInitialData;

    if (_isFetchingInitialData) {
      currentStatusText = 'Memuat lokasi & status absensi...';
      actionButtonText = 'Memuat...';
      showActionButton = true;
    } else if (_displayMessage != null &&
        (_todayAttendance == null || _todayAttendance?.status == null)) {
      // Kasus khusus: _todayAttendance null, tapi _displayMessage punya info
      if (_displayMessage!.contains('Izin lokasi ditolak') ||
          _displayMessage!.contains('Layanan lokasi tidak diaktifkan')) {
        currentStatusText = 'Error Lokasi: $_displayMessage';
        actionButtonText =
            'Aktifkan Lokasi'; // Tombol untuk refresh/aktifkan lokasi
        showActionButton = true;
      } else if (_displayMessage!.contains(
        'Belum ada data absensi pada tanggal tersebut',
      )) {
        currentStatusText =
            'Anda belum absen hari ini.'; // Ini adalah info normal, bukan error
        actionButtonText = 'Mulai Absensi';
        showActionButton = true;
      } else {
        // Ini adalah error API/sistem yang tidak spesifik lokasi atau 'no data'
        currentStatusText = 'Error: $_displayMessage';
        actionButtonText = 'Coba Lagi'; // Tombol untuk coba refresh data
        showActionButton = true;
      }
    } else if (_todayAttendance?.status == 'masuk') {
      if (_todayAttendance!.checkOut == null) {
        currentStatusText =
            'Anda sudah Check In pada ${_todayAttendance!.checkIn ?? 'N/A'}.';
        actionButtonText = 'Check Out';
        showActionButton = true;
      } else {
        currentStatusText =
            'Anda sudah Check In & Check Out pada ${_todayAttendance!.checkOut ?? 'N/A'}.';
        actionButtonText = 'Absensi Selesai Hari Ini';
        showActionButton = false; // Tidak ada aksi lagi hari ini
      }
    } else if (_todayAttendance?.status == 'izin') {
      currentStatusText =
          'Anda sudah Izin hari ini karena ${_todayAttendance!.reason ?? 'alasan tidak dicatat'}.';
      actionButtonText = 'Anda Sedang Izin';
      showActionButton = false; // Tidak ada aksi lagi hari ini
    } else {
      // Catch-all: Seharusnya tidak tercapai jika logika di atas lengkap.
      // Ini bisa terjadi jika _todayAttendance tidak null tapi statusnya tidak dikenal.
      currentStatusText = 'Status absensi tidak dikenal.';
      actionButtonText = 'Mulai Absensi';
      showActionButton = true;
    }

    // Tentukan warna teks status di UI
    Color statusTextColor;
    if (currentStatusText.contains('Error') ||
        currentStatusText.contains('ditolak') ||
        currentStatusText.contains('Belum Check In')) {
      statusTextColor = Colors.red;
    } else if (currentStatusText.contains('Check In pada') ||
        currentStatusText.contains('Izin hari ini')) {
      statusTextColor = Colors.green;
    } else if (currentStatusText.contains('Absensi Selesai') ||
        currentStatusText.contains('Izin hari ini')) {
      statusTextColor = Colors.orange; // Misalnya untuk "selesai" atau "izin"
    } else {
      statusTextColor = AppColors.textDark;
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
                      : _officePosition, // Default ke posisi kantor jika lokasi belum terdeteksi
              zoom: 15.0,
            ),
            markers: _markers,
            // Tombol My Location Button dari Google Maps (opsional, kita buat sendiri)
            myLocationButtonEnabled: false,
            myLocationEnabled: _isLocationPermissionsGrantedAndReady,
            zoomControlsEnabled: true, // Biarkan kontrol zoom terlihat
            compassEnabled: true,
          ),

          // Card "Check in" di atas peta (menggunakan DraggableScrollableSheet untuk UI lebih baik)
          Positioned.fill(
            child: DraggableScrollableSheet(
              initialChildSize:
                  0.4, // Ukuran awal sheet (40% dari tinggi layar)
              minChildSize: 0.15, // Ukuran minimum saat digeser ke bawah
              maxChildSize: 0.8, // Ukuran maksimum saat digeser ke atas
              snap:
                  true, // Membuat sheet menempel di initialChildSize atau maxChildSize
              builder: (
                BuildContext context,
                ScrollController scrollController,
              ) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.loginCardColor, // Warna kartu
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
                  child: RefreshIndicator(
                    // RefreshIndicator di dalam DraggableSheet
                    onRefresh:
                        _initializePageData, // Panggil metode untuk refresh semua data
                    color: AppColors.loginButtonColor,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      controller:
                          scrollController, // Penting agar sheet bisa discroll
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize:
                            MainAxisSize
                                .min, // Agar Column tidak mengambil tinggi penuh
                        children: [
                          // Handle bar di atas sheet
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
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
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                                    // Tampilkan indikator loading atau alamat
                                    _isFetchingInitialData &&
                                            _currentAddress.contains(
                                              'Mendapatkan lokasi',
                                            )
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
                                    // Tampilkan jarak dari kantor
                                    if (!_isFetchingInitialData &&
                                        _currentLat != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          'Jarak dari kantor: ${_distanceFromOffice.toStringAsFixed(0)} meter',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color:
                                                _distanceFromOffice >
                                                        _allowedRadius
                                                    ? Colors
                                                        .red // Jika di luar radius
                                                    : Colors
                                                        .green, // Jika di dalam radius
                                            fontWeight: FontWeight.bold,
                                          ),
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
                          // Row(
                          //   children: [
                          //     const Icon(
                          //       Icons.notes,
                          //       color: Colors.black,
                          //       size: 24,
                          //     ),
                          //     const SizedBox(width: 10),
                          //     Text(
                          //       'Catatan (Opsional)',
                          //       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          //             fontWeight: FontWeight.bold,
                          //             color: AppColors.textDark,
                          //           ),
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(height: 10),
                          // TextField(
                          //   controller: _noteController,
                          //   decoration: InputDecoration(
                          //     hintText: 'Tambahkan catatan jika perlu...',
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     filled: true,
                          //     fillColor: Colors.grey[200],
                          //     contentPadding: const EdgeInsets.symmetric(
                          //       horizontal: 15,
                          //       vertical: 10,
                          //     ),
                          //   ),
                          //   maxLines: 2,
                          //   enabled:
                          //       !interactionDisabled, // Nonaktifkan saat loading
                          // ),
                          const SizedBox(height: 25),
                          // Status Absensi Hari Ini
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                interactionDisabled
                                    ? const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    )
                                    : Text(
                                      'Status Absensi : $currentStatusText',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        color: statusTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 10),
                          // Tombol Aksi Utama
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  interactionDisabled || !showActionButton
                                      ? null // Tombol dinonaktifkan jika loading atau tidak ada aksi
                                      : _showAttendanceActionDialog, // Selalu panggil dialog aksi utama
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    (actionButtonText.contains('Aktifkan') ||
                                            actionButtonText.contains(
                                              'Coba Lagi',
                                            ))
                                        ? Colors
                                            .orange // Warna oranye untuk aksi pemulihan/error
                                        : (actionButtonText.contains(
                                          'Check Out',
                                        ))
                                        ? AppColors
                                            .loginAccentColor // Warna aksen untuk Check Out
                                        : AppColors
                                            .loginButtonColor, // Warna utama untuk Check In/Mulai Absensi
                                foregroundColor: AppColors.textLight,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child:
                                  interactionDisabled
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      ) // Indikator loading
                                      : Text(
                                        actionButtonText,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                          // const SizedBox(
                          //   height: 20,
                          // ), // Spasi di bagian bawah sheet
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // StreamBuilder untuk menampilkan jam real-time di pojok kanan atas
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: StreamBuilder<DateTime>(
                stream: _clockStream,
                builder: (context, snapshot) {
                  final currentTime = snapshot.data ?? DateTime.now();
                  return Text(
                    DateFormat('HH:mm:ss', 'id_ID').format(currentTime),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          // Tombol My Location di pojok kiri atas (custom, bukan bawaan Google Maps)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed:
                  _initializePageData, // Panggil untuk refresh lokasi dan data
              child: Icon(Icons.my_location, color: AppColors.loginButtonColor),
            ),
          ),
        ],
      ),
    );
  }
}

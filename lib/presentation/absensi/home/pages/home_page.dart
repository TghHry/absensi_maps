// lib/presentation/absensi/home/pages/home_page.dart

import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/models/session_manager.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

import 'package:absensi_maps/api/api_service.dart';
import 'package:absensi_maps/presentation/absensi/attandance/services/attandance_service.dart';
// Import model User dan ProfileService
import 'package:absensi_maps/models/user_model.dart'; // Import model User
import 'package:absensi_maps/models/profile_model.dart'; // Import ProfileUser dan ProfileResponse
import 'package:absensi_maps/presentation/absensi/profile/services/profile_service.dart'; // Import ProfileService

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Data statistik absensi dari API
  Map<String, dynamic>? _attendanceStats;
  bool _isLoadingStats = true;
  String? _statsErrorMessage;
  String? _token;

  // Data profil pengguna
  ProfileUser?
  _userProfile; // Menggunakan ProfileUser karena memiliki fullProfilePhotoUrl
  bool _isLoadingProfile = true; // Loading state terpisah untuk profil
  String? _profileErrorMessage;

  // Untuk live clock di UI
  late Stream<DateTime> _clockStream;

  // Inisialisasi service
  final AttendanceService _attendanceService = AttendanceService();
  final SessionManager _sessionManager = SessionManager();
  final ProfileService _profileService =
      ProfileService(); // Inisialisasi ProfileService

  @override
  void initState() {
    super.initState();
    debugPrint('HomePage: initState terpanggil.');
    _fetchHomePageData(); // Memuat semua data yang dibutuhkan Home Page
    _clockStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  // Metode gabungan untuk mengambil semua data yang dibutuhkan Home Page
  Future<void> _fetchHomePageData() async {
    await Future.wait([
      _fetchUserProfile(), // Ambil data profil
      _fetchAttendanceStats(), // Ambil data statistik
    ]);
  }

  // Mengambil data profil user terbaru
  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
      _profileErrorMessage = null;
    });

    try {
      _token = await _sessionManager.getToken(); // Pastikan token sudah ada
      if (_token == null || _token!.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      final ProfileResponse response = await _profileService.fetchUserProfile(
        _token!,
      );
      if (!mounted) return;

      if (response.data != null) {
        setState(() {
          _userProfile = response.data;
        });
        // Opsional: Perbarui user di SessionManager jika data profil lebih baru
        final DateTime userCreatedAt =
            response.data!.createdAt ?? DateTime(2000, 1, 1);
        final DateTime userUpdatedAt =
            response.data!.updatedAt ?? DateTime(2000, 1, 1);
        final User fetchedUser = User(
          id: response.data!.id,
          name: response.data!.name,
          email: response.data!.email,
          emailVerifiedAt: response.data!.emailVerifiedAt,
          createdAt: userCreatedAt,
          updatedAt: userUpdatedAt,
          batchId: response.data!.batchId,
          trainingId: response.data!.trainingId,
          jenisKelamin: response.data!.jenisKelamin,
          profilePhotoPath: response.data!.profilePhoto,
          onesignalPlayerId: response.data!.onesignalPlayerId,
          batch: response.data!.batch,
          training: response.data!.training,
        );
        await _sessionManager.saveUser(fetchedUser);
      } else {
        _profileErrorMessage =
            response.message ?? 'Tidak ada data profil ditemukan.';
      }
    } catch (e) {
      debugPrint('HomePage: Error fetching user profile: $e');
      if (!mounted) return;
      setState(() {
        _profileErrorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      if (e.toString().contains('token tidak valid') ||
          e.toString().contains('Sesi Anda telah berakhir') ||
          e.toString().contains('Token has expired')) {
        _sessionManager.clearSession().then((_) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi Anda telah berakhir. Mohon login kembali.'),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: $_profileErrorMessage')),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _fetchAttendanceStats() async {
    if (!mounted) return;
    setState(() {
      _isLoadingStats = true;
      _statsErrorMessage = null;
    });

    try {
      _token = await _sessionManager.getToken();
      if (_token == null || _token!.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      final Map<String, dynamic> response = await ApiService.getAbsenStats(
        _token!,
      );
      debugPrint('HomePage: Absen Stats API response raw: $response');

      if (!mounted) return;
      setState(() {
        if (response['data'] != null && response['data'] is Map) {
          _attendanceStats = response['data'] as Map<String, dynamic>;

          _attendanceStats!['total_absen_count'] =
              int.tryParse(
                _attendanceStats!['total_absen']?.toString() ?? '0',
              ) ??
              0;
          _attendanceStats!['total_masuk_count'] =
              int.tryParse(
                _attendanceStats!['total_masuk']?.toString() ?? '0',
              ) ??
              0;
          _attendanceStats!['total_izin_count'] =
              int.tryParse(
                _attendanceStats!['total_izin']?.toString() ?? '0',
              ) ??
              0;

          _attendanceStats!['has_checked_in_today'] =
              _attendanceStats!['sudah_absen_hari_ini'] == true;
          // 'has_checked_out_today' tidak langsung tersedia di /absen/stats,
          // jika diperlukan, harus diambil dari /absen/today atau ditambahkan di backend.
          // Untuk saat ini, kita bisa default ke false atau berdasarkan logika tambahan.
          _attendanceStats!['has_checked_out_today'] =
              false; // Default sementara

          debugPrint(
            'HomePage: _attendanceStats setelah parsing: $_attendanceStats',
          );
        } else {
          _statsErrorMessage =
              response['message'] ??
              'Tidak ada data statistik ditemukan atau format tidak valid.';
          debugPrint(
            'HomePage: Data statistik null atau bukan Map: ${response['data']}',
          );
        }
      });
    } catch (e) {
      debugPrint('HomePage: Error fetching attendance stats: $e');
      if (!mounted) return;
      setState(() {
        _statsErrorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      if (e.toString().contains('token tidak valid') ||
          e.toString().contains('Sesi Anda telah berakhir') ||
          e.toString().contains('Token has expired')) {
        _sessionManager.clearSession().then((_) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi Anda telah berakhir. Mohon login kembali.'),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat statistik: $_statsErrorMessage'),
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomePage: build terpanggil.');
    final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width; // Tidak digunakan di sini, bisa dihapus

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Gambar latar belakang
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/dashboard.jpg', // Pastikan path gambar benar
              fit: BoxFit.cover,
            ),
          ),

          // Konten utama halaman
          RefreshIndicator(
            onRefresh:
                _fetchHomePageData, // Refresh semua data (profil & statistik)
            color: AppColors.homeTopBlue,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
              ), // Padding dari status bar
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10), // Spasi awal
                  // Bagian Profil Pengguna
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child:
                        _isLoadingProfile
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : _profileErrorMessage != null
                            ? Center(
                              child: Text(
                                'Error memuat profil: $_profileErrorMessage',
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            )
                            : (_userProfile == null
                                ? const Center(
                                  child: Text(
                                    'Data profil tidak tersedia.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                                : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Circle Avatar Profile
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: AppColors.homeTopBlue,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child:
                                            (_userProfile!.fullProfilePhotoUrl !=
                                                        null &&
                                                    _userProfile!
                                                        .fullProfilePhotoUrl!
                                                        .isNotEmpty)
                                                ? Image.network(
                                                  _userProfile!
                                                      .fullProfilePhotoUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    debugPrint(
                                                      'Error loading profile photo: $error',
                                                    );
                                                    return Icon(
                                                      Icons.person,
                                                      size: 40,
                                                      color: Colors.grey[600],
                                                    );
                                                  },
                                                )
                                                : Image.asset(
                                                  'assets/images/user_avatar.png', // Default avatar
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    debugPrint(
                                                      'Error loading default avatar: $error',
                                                    );
                                                    return Icon(
                                                      Icons.person,
                                                      size: 40,
                                                      color: Colors.grey[600],
                                                    );
                                                  },
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    // Nama dan Email
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _userProfile!.name,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  AppColors
                                                      .textDark, // Warna teks putih
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            _userProfile!.email,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color: AppColors.textDark
                                                  .withOpacity(
                                                    0.8,
                                                  ), // Sedikit transparan
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                  ),
                  const SizedBox(height: 30),

                  // Live Attendance Card (pindahkan ke bawah profil)
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Live Attendance',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: StreamBuilder<DateTime>(
                            stream: _clockStream,
                            builder: (context, snapshot) {
                              final currentTime =
                                  snapshot.data ?? DateTime.now();
                              return Text(
                                DateFormat(
                                  'HH:mm:ss',
                                  'id_ID',
                                ).format(currentTime),
                                style: Theme.of(
                                  context,
                                ).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.homeTopBlue,
                                ),
                              );
                            },
                          ),
                        ),
                        Center(
                          child: Text(
                            DateFormat(
                              'EEE, dd MMMM yyyy',
                              'id_ID',
                            ).format(now),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                        const Divider(height: 30, thickness: 1),
                        Text(
                          'Office Hours',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '08:00 AM - 05:00 PM',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Attendance Stats Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Statistik Absensi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _isLoadingStats
                      ? const Center(child: CircularProgressIndicator())
                      : _statsErrorMessage != null
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Gagal memuat statistik: $_statsErrorMessage',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20.0),
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: AppColors.homeCardBackground,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildStatRow(
                              context,
                              Icons.calendar_today,
                              'Total Absen',
                              '${_attendanceStats!['total_absen_count']} hari',
                            ),
                            _buildStatRow(
                              context,
                              Icons.check_circle_outline,
                              'Total Masuk',
                              '${_attendanceStats!['total_masuk_count']} hari',
                            ),
                            _buildStatRow(
                              context,
                              Icons.event_busy,
                              'Total Izin',
                              '${_attendanceStats!['total_izin_count']} hari',
                            ),
                            _buildStatRow(
                              context,
                              Icons.today,
                              'Sudah Absen Hari Ini',
                              _getTodayAttendanceStatusText(
                                _attendanceStats!['has_checked_in_today'] ??
                                    false,
                              ),
                              color: _getTodayAttendanceStatusColor(
                                _attendanceStats!['has_checked_in_today'] ??
                                    false,
                              ),
                            ),

                            // Untuk "Sudah Logout Hari Ini", kita perlu data dari /absen/today
                            // Jika API stats tidak menyediakan, ini akan tetap "Belum" atau Anda perlu memodifikasi backend.
                          ],
                        ),
                      ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        
        ],
      ),
    );
  }

  // Metode pembantu untuk mendapatkan teks status absensi hari ini
  String _getTodayAttendanceStatusText(bool hasCheckedInToday) {
    if (_attendanceStats == null) {
      return 'Memuat...';
    }
    return hasCheckedInToday ? 'Ya' : 'Belum';
  }

  // Metode pembantu untuk mendapatkan warna status absensi hari ini
  Color _getTodayAttendanceStatusColor(bool hasCheckedInToday) {
    if (_attendanceStats == null) {
      return Colors.grey;
    }
    return hasCheckedInToday ? Colors.green : Colors.red;
  }

  // Perbarui _buildStatRow untuk menerima IconData dan optional color
  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

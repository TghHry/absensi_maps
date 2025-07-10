// File: lib/presentation/absensi/profile/pages/profile_page.dart

import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/models/profile_model.dart';
import 'package:absensi_maps/presentation/absensi/profile/edit_profile/pages/edit_profile_page.dart';
import 'package:absensi_maps/presentation/absensi/profile/services/profile_service.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk mendapatkan token
import 'package:shared_preferences/shared_preferences.dart'; // Untuk logout
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:absensi_maps/api/api_service.dart'; // Tambahkan ini untuk akses ApiService.tokenKey

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileUser? _userProfile; // Ubah tipe menjadi ProfileUser?
  bool _isLoading = true;
  String? _errorMessage;

  final ProfileService _profileService = ProfileService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Panggil fungsi untuk mengambil data profil
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset error message
    });

    try {
      final String? token = await _secureStorage.read(
        key: ApiService.tokenKey,
      ); // Menggunakan ApiService.tokenKey
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      // Aktifkan baris ini dan pastikan ProfileService mengembalikan ProfileResponse
      final ProfileResponse response = await _profileService.fetchUserProfile(
        token,
      );

      if (!mounted) return;
      setState(() {
        _userProfile =
            response.data; // response.data sekarang adalah ProfileUser
      });
      debugPrint('Data profil berhasil diambil: ${_userProfile?.name}');
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      // Penanganan khusus untuk token tidak valid atau sesi berakhir
      if (e.toString().contains('token tidak valid') ||
          e.toString().contains('Sesi Anda telah berakhir') ||
          e.toString().contains('Token has expired')) {
        _performLogout(); // Langsung logout jika token tidak valid
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performLogout() async {
    // Pastikan mounted sebelum navigasi dan SnackBar
    if (!mounted) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('SharedPreferences dibersihkan.');

    await _secureStorage.deleteAll();
    debugPrint('FlutterSecureStorage dibersihkan.');

    if (!mounted) return; // Cek mounted lagi sebelum navigasi
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/', // Kembali ke halaman login
      (Route<dynamic> route) => false,
    );
    // SnackBar bisa ditampilkan setelah navigasi, atau sebelum jika Anda ingin pesan muncul di halaman login
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Anda telah logout.')));
  }

  void _navigateToEditProfile() async {
    if (_userProfile == null) {
      // Tampilkan pesan jika profil belum dimuat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil belum dimuat. Mohon tunggu atau coba lagi.'),
        ),
      );
      return;
    }

    // Kirim objek _userProfile (yang bertipe ProfileUser) ke halaman EditProfilePage
    final updatedUser = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(currentUser: _userProfile!),
      ),
    );

    // Jika ada data ProfileUser yang dikembalikan dari EditProfilePage, update state
    if (updatedUser != null && updatedUser is ProfileUser) {
      // Pastikan tipenya ProfileUser
      setState(() {
        _userProfile = updatedUser;
      });
      // Opsional: Perbarui juga SharedPreferences jika Anda menyimpan data profil lengkap di sana
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width; // Tidak digunakan langsung di sini

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Latar Belakang Atas (Kuning & Biru)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.35,
              color: AppColors.homeTopYellow,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _ProfileBlueClipper(
                MediaQuery.of(context).size.width,
                screenHeight * 0.35,
              ),
              child: Container(
                height: screenHeight * 0.35,
                color: AppColors.homeTopBlue,
              ),
            ),
          ),
          // Konten Utama (Scrollable)
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 48,
                            ), // Spacer untuk menyeimbangkan icon
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Profil',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: AppColors.textLight,
                                size: 28,
                              ),
                              onPressed: _performLogout,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child:
                              _isLoading // Tampilkan loading atau error atau konten profil
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : _errorMessage != null
                                  ? Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                  : Column(
                                    children: [
                                      // Avatar User
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: AppColors.homeTopBlue,
                                            width: 3,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: InkWell(
                                            onTap: _navigateToEditProfile,
                                            child:
                                                _userProfile?.profilePhoto !=
                                                            null &&
                                                        _userProfile!
                                                            .profilePhoto!
                                                            .isNotEmpty
                                                    ? Image.network(
                                                      _userProfile!
                                                          .profilePhoto!,
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
                                                          size: 60,
                                                          color:
                                                              Colors.grey[600],
                                                        );
                                                      },
                                                    )
                                                    : Image.asset(
                                                      'assets/images/user_avatar.png', // Pastikan path ini benar di pubspec.yaml
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
                                                          size: 60,
                                                          color:
                                                              Colors.grey[600],
                                                        );
                                                      },
                                                    ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        _userProfile?.name ??
                                            'Nama Pengguna', // Nama
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.copyWith(
                                          color: AppColors.textLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _userProfile?.trainingTitle ??
                                            'Jabatan/Jurusan', // training_title dari getter di ProfileUser
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textLight
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                      Text(
                                        'Batch Ke: ${_userProfile?.batchKe ?? 'Tidak Tersedia'}', // batch_ke dari getter di ProfileUser
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textLight
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Konten Card Informasi
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    padding: const EdgeInsets.all(25.0),
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
                    child:
                        _isLoading // Tampilkan loading atau error atau detail profil
                            ? const Center(child: CircularProgressIndicator())
                            : _errorMessage != null
                            ? Center(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informasi Pribadi',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                // Baris informasi pribadi dengan ikon
                                _buildInfoRow(
                                  context,
                                  Icons.person, // Ikon Nama
                                  'Nama Lengkap',
                                  _userProfile?.name ?? 'Tidak Tersedia',
                                ),
                                _buildInfoRow(
                                  context,
                                  Icons.email, // Ikon Email
                                  'Email',
                                  _userProfile?.email ?? 'Tidak Tersedia',
                                ),
                                _buildInfoRow(
                                  context,
                                  Icons.wc, // Ikon Jenis Kelamin
                                  'Jenis Kelamin',
                                  _userProfile?.jenisKelamin == 'L'
                                      ? 'Laki-laki'
                                      : (_userProfile?.jenisKelamin == 'P'
                                          ? 'Perempuan'
                                          : 'Tidak Tersedia'),
                                ),
                                _buildInfoRow(
                                  context,
                                  Icons.school, // Ikon Jurusan
                                  'Jurusan/Training',
                                  _userProfile?.training?.title ??
                                      'Tidak Tersedia',
                                ),
                                _buildInfoRow(
                                  context,
                                  Icons.group, // Ikon Batch
                                  'Batch Ke',
                                  _userProfile?.batch?.batchKe ??
                                      'Tidak Tersedia',
                                ),
                                // Hapus detail Batch, Deskripsi, Akun Dibuat, dan Terakhir Diupdate
                                // Sisa dari sini adalah tombol
                                const SizedBox(height: 25),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _navigateToEditProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.loginButtonColor,
                                      foregroundColor: AppColors.textLight,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Edit Profil',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _performLogout,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: AppColors.textLight,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  ),
                  const SizedBox(height: 100), // Padding bawah agar bisa scroll
                ],
              ),
            ),
          ),
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

  // Widget helper untuk menampilkan baris informasi
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: AppColors.textDark,
            size: 24,
          ), // <--- ICON DITAMBAHKAN
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Expanded(
            // Gunakan Expanded agar teks value tidak overflow
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2, // Batasi jumlah baris jika teks terlalu panjang
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper untuk memotong bentuk biru di bagian atas (tetap sama)
class _ProfileBlueClipper extends CustomClipper<Path> {
  final double screenWidth;
  final double clipHeight;

  _ProfileBlueClipper(this.screenWidth, this.clipHeight);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 1.0,
      size.width * 0.5,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.8,
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

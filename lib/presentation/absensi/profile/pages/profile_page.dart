import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/presentation/absensi/auth/login/models/login_model.dart';
import 'package:absensi_maps/presentation/absensi/profile/models/profile_model.dart';
import 'package:absensi_maps/presentation/absensi/profile/services/profile_service.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk membaca user data (id, name, email)
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk membaca token
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _userProfile; // Untuk menyimpan data profil pengguna yang diambil
  bool _isLoading = true; // State untuk indikator loading
  String? _errorMessage; // Untuk menyimpan pesan error jika terjadi

  final ProfileService _profileService = ProfileService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Panggil fungsi untuk mengambil data profil saat halaman dimuat
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset error message
    });

    try {
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
      }

      final ProfileResponse response = await _profileService.fetchUserProfile(token);

      setState(() {
        _userProfile = response.data.user; // Set data user dari respons
      });
      debugPrint('Data profil berhasil diambil: ${_userProfile?.name}');
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', ''); // Hapus "Exception: "
      });
      // Opsional: Jika token tidak valid, arahkan ke halaman login
      if (e.toString().contains('token tidak valid') || e.toString().contains('Sesi Anda telah berakhir')) {
        _performLogout(); // Otomatis logout jika token tidak valid
      }
    } finally {
      setState(() {
        _isLoading = false; // Sembunyikan loading
      });
    }
  }

  Future<void> _performLogout() async {
    // Hapus semua data dari SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('SharedPreferences dibersihkan.');

    // Hapus semua data dari FlutterSecureStorage
    await _secureStorage.deleteAll();
    debugPrint('FlutterSecureStorage dibersihkan.');

    // Navigasi ke halaman login dan hapus semua rute sebelumnya
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/', // Asumsi '/' adalah rute ke LoginPage Anda
      (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anda telah logout.')),
    );
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
          // Latar belakang kuning dan biru di bagian atas
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
              clipper: _ProfileBlueClipper(screenWidth, screenHeight * 0.35),
              child: Container(
                height: screenHeight * 0.35,
                color: AppColors.homeTopBlue,
              ),
            ),
          ),
          // Konten utama halaman
          SingleChildScrollView(
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
                          const SizedBox(width: 48), // Spacer agar icon logout ada di kanan
                          Expanded(
                            child: Center(
                              child: Text(
                                'Profil', // Judul halaman
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          // Tombol Logout
                          IconButton(
                            icon: const Icon(
                              Icons.logout, // Icon logout
                              color: AppColors.textLight,
                              size: 28,
                            ),
                            onPressed: _performLogout, // Panggil fungsi logout
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white) // Indikator loading
                            : _errorMessage != null
                                ? Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ) // Pesan error
                                : Column(
                                    children: [
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
                                            onTap: () {
                                              // Navigasi ke edit profil
                                              Navigator.pushNamed(context, '/edit_profile');
                                            },
                                            child: Image.asset(
                                              'assets/images/user_avatar.png', // Pastikan path ini benar
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.grey[600],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        _userProfile?.name ?? 'Nama Pengguna', // Tampilkan nama dari API
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: AppColors.textLight,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      // TODO: Sesuaikan dengan data yang Anda miliki dari API jika ada ID/Jabatan terpisah
                                      Text(
                                        _userProfile?.email ?? 'Jabatan', // Tampilkan email atau placeholder
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppColors.textLight.withOpacity(0.8),
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
                  child: _isLoading // Tampilkan loading atau data
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informasi Pribadi', // Disesuaikan ke Bahasa Indonesia
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                ),
                                const SizedBox(height: 15),
                                _buildInfoRow(context, 'Nama', _userProfile?.name ?? 'Tidak Tersedia'),
                                _buildInfoRow(context, 'Email', _userProfile?.email ?? 'Tidak Tersedia'),
                                // TODO: Jika API Anda menyediakan nomor telepon, tambahkan di sini
                                _buildInfoRow(context, 'No. Hp', 'Tidak Tersedia'), // Placeholder
                                const SizedBox(height: 25),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // TODO: Navigasi ke halaman ubah kata sandi
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ubah Kata Sandi ditekan!'),
                                        ),
                                      );
                                      // Contoh navigasi ke halaman ubah password
                                      // Navigator.pushNamed(context, '/change_password');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.loginButtonColor,
                                      foregroundColor: AppColors.textLight,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Ubah Kata Sandi', // Disesuaikan ke Bahasa Indonesia
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
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

  // Widget helper untuk baris informasi
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper untuk memotong bentuk biru di bagian atas (mirip History)
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
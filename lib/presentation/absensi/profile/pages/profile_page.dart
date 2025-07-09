// File: lib/presentation/absensi/profile/pages/profile_page.dart
import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/presentation/absensi/profile/edit_profile/pages/edit_profile_page.dart';
import 'package:absensi_maps/presentation/absensi/profile/models/profile_model.dart';
import 'package:absensi_maps/presentation/absensi/profile/services/profile_service.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk mendapatkan token
import 'package:shared_preferences/shared_preferences.dart'; // Untuk logout
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:flutter/foundation.dart'; // Untuk debugPrint

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
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
      }

      final ProfileResponse response = await _profileService.fetchUserProfile(token);
      if (!mounted) return;
      setState(() {
        _userProfile = response.data; // response.data sekarang adalah ProfileUser
      });
      debugPrint('Data profil berhasil diambil: ${_userProfile?.name}');
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      if (e.toString().contains('token tidak valid') || e.toString().contains('Sesi Anda telah berakhir')) {
        _performLogout();
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('SharedPreferences dibersihkan.');

    await _secureStorage.deleteAll();
    debugPrint('FlutterSecureStorage dibersihkan.');

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anda telah logout.')),
    );
  }

  void _navigateToEditProfile() async {
    if (_userProfile == null) return;

    // Kirim objek _userProfile (yang bertipe ProfileUser) ke halaman EditProfilePage
    final updatedUser = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(currentUser: _userProfile!),
      ),
    );

    // Jika ada data ProfileUser yang dikembalikan dari EditProfilePage, update state
    if (updatedUser != null && updatedUser is ProfileUser) { // Pastikan tipenya ProfileUser
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
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
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
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
                            const SizedBox(width: 48), // Spacer
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Profil',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: AppColors.textLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: AppColors.textLight, size: 28),
                              onPressed: _performLogout,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : _errorMessage != null
                                  ? Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red, fontSize: 16),
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
                                            border: Border.all(color: AppColors.homeTopBlue, width: 3),
                                          ),
                                          child: ClipOval(
                                            child: InkWell(
                                              onTap: _navigateToEditProfile,
                                              child: _userProfile?.profilePhoto != null && _userProfile!.profilePhoto!.isNotEmpty
                                                  ? Image.network(
                                                      _userProfile!.profilePhoto!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(Icons.person, size: 60, color: Colors.grey[600]);
                                                      },
                                                    )
                                                  : Image.asset(
                                                      'assets/images/user_avatar.png', // Pastikan path ini benar
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(Icons.person, size: 60, color: Colors.grey[600]);
                                                      },
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          _userProfile?.name ?? 'Nama Pengguna', // Nama
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                color: AppColors.textLight,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          _userProfile?.trainingTitle ?? 'Jabatan/Jurusan', // training_title
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: AppColors.textLight.withOpacity(0.8),
                                              ),
                                        ),
                                        Text(
                                          'Batch Ke: ${_userProfile?.batchKe ?? 'Tidak Tersedia'}', // batch_ke
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                    child: _isLoading
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
                                    'Informasi Pribadi',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildInfoRow(context, 'Nama Lengkap', _userProfile?.name ?? 'Tidak Tersedia'),
                                  _buildInfoRow(context, 'Email', _userProfile?.email ?? 'Tidak Tersedia'),
                                  _buildInfoRow(context, 'Jenis Kelamin', _userProfile?.jenisKelamin ?? 'Tidak Tersedia'),
                                  // Detail Batch
                                  const SizedBox(height: 15),
                                  Text(
                                    'Detail Batch',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildInfoRow(context, 'Batch Ke', _userProfile?.batch?.batchKe ?? 'Tidak Tersedia'),
                                  _buildInfoRow(context, 'Mulai Batch', _userProfile?.batch?.startDate != null ? DateFormat('dd MMM yyyy').format(_userProfile!.batch!.startDate!) : 'Tidak Tersedia'),
                                  _buildInfoRow(context, 'Akhir Batch', _userProfile?.batch?.endDate != null ? DateFormat('dd MMM yyyy').format(_userProfile!.batch!.endDate!) : 'Tidak Tersedia'),
                                  // Detail Training
                                  const SizedBox(height: 15),
                                  Text(
                                    'Detail Jurusan/Training',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildInfoRow(context, 'Nama Jurusan', _userProfile?.training?.title ?? 'Tidak Tersedia'),
                                  _buildInfoRow(context, 'Deskripsi', _userProfile?.training?.description ?? 'Tidak Tersedia'),
                                  _buildInfoRow(context, 'Peserta', _userProfile?.training?.participantCount?.toString() ?? 'Tidak Tersedia'),
                                  // Created At dan Updated At
                                  const SizedBox(height: 15),
                                  _buildInfoRow(context, 'Akun Dibuat', _userProfile?.createdAt != null ? DateFormat('dd MMM yyyy HH:mm').format(_userProfile!.createdAt!) : 'Tidak Tersedia'),
                                  _buildInfoRow(context, 'Terakhir Diupdate', _userProfile?.updatedAt != null ? DateFormat('dd MMM yyyy HH:mm').format(_userProfile!.updatedAt!) : 'Tidak Tersedia'),
                                  
                                  const SizedBox(height: 25),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _navigateToEditProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.loginButtonColor,
                                        foregroundColor: AppColors.textLight,
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
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
    );
  }

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
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
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
      size.width * 0.2, size.height * 1.0,
      size.width * 0.5, size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.8,
      size.width, size.height * 0.4,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
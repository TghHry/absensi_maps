// lib/presentation/absensi/profile/pages/profile_page.dart

import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/models/profile_model.dart';
import 'package:absensi_maps/presentation/absensi/profile/services/profile_service.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:absensi_maps/api/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileUser? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  final ProfileService _profileService = ProfileService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      final ProfileResponse response = await _profileService.fetchUserProfile(
        token,
      );
      if (!mounted) return;

      if (response.data != null) {
        setState(() {
          _userProfile = response.data;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Gagal memuat profil: ${e.toString().replaceFirst('Exception: ', '')}';
      });
      if (e.toString().contains('token tidak valid') ||
          e.toString().contains('Sesi Anda telah berakhir') ||
          e.toString().contains('Token has expired')) {
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
    if (!mounted) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('SharedPreferences dibersihkan.');

    await _secureStorage.deleteAll();
    debugPrint('FlutterSecureStorage dibersihkan.');

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Anda telah logout.')));
  }

  void _showEditNameDialog() {
    if (_userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil belum dimuat. Mohon tunggu.')),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController(
      text: _userProfile!.name,
    );
    final _formKeyDialog = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Nama Lengkap'),
          content: Form(
            key: _formKeyDialog,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tidak boleh kosong.';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan'),
              onPressed:
                  _isLoading
                      ? null
                      : () async {
                        if (!_formKeyDialog.currentState!.validate()) {
                          return;
                        }

                        final String newName = nameController.text.trim();

                        if (newName == _userProfile!.name) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama tidak berubah.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          Navigator.of(dialogContext).pop();
                          return;
                        }

                        Navigator.of(dialogContext).pop();
                        _updateProfileNameOnServer(newName);
                      },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfileNameOnServer(String newName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      if (_userProfile == null) {
        throw Exception('Profil tidak dimuat, tidak bisa menyimpan perubahan.');
      }

      // Pastikan hanya mengirim nama yang diubah, jika API backend hanya menerima itu.
      // Jika API menerima PATCH atau PUT dengan partial update, maka ini sudah benar.
      final ProfileResponse response = await _profileService.updateProfileData(
        token,
        name: newName,
        // Hapus: jenisKelamin, trainingId, batchId dari sini jika backend hanya ingin nama
      );

      if (!mounted) return;

      if (response.data != null) {
        setState(() {
          _userProfile =
              response.data; // UI akan diperbarui dengan data dari respons API
        });

        // Perbarui juga data di SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', response.data!.name);
        // Pertimbangkan apakah perlu update SharedPreferences untuk field lain.
        // Jika profile_model.dart menyimpan semua data, dan API hanya mengubah nama,
        // maka data lain di SharedPreferences yang terkait dengan training/batch
        // akan tetap ada dari fetchUserProfile terakhir.
        // Namun, jika Anda menyimpan seluruh objek JSON user di SharedPreferences,
        // Anda mungkin perlu update seluruh string JSON tersebut.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Update profile name failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan perubahan nama: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body:
          _isLoading && _userProfile == null && _errorMessage == null
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : _userProfile == null
              ? const Center(child: Text('Tidak ada data profil ditemukan.'))
              : Stack(
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
                        screenWidth,
                        screenHeight * 0.35,
                      ),
                      child: Container(
                        height: screenHeight * 0.35,
                        color: AppColors.homeTopBlue,
                      ),
                    ),
                  ),
                  // Konten Utama (Scrollable)
                  // --- Widget RefreshIndicator ditambahkan di sini ---
                  Positioned.fill(
                    child: RefreshIndicator(
                      onRefresh:
                          _fetchUserProfile, // Panggil metode refresh Anda
                      color: AppColors.homeTopBlue, // Warna indikator refresh
                      backgroundColor:
                          Colors.white, // Warna latar belakang indikator
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [const SizedBox(width: 48)],
                              ),
                            ),
                            const SizedBox(height: 20),
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
                                  child:
                                      _userProfile!.profilePhoto != null &&
                                              _userProfile!
                                                  .profilePhoto!
                                                  .isNotEmpty
                                          ? Image.network(
                                            _userProfile!.profilePhoto!,
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
                                                color: Colors.grey[600],
                                              );
                                            },
                                          )
                                          : Image.asset(
                                            'assets/images/user_avatar.png',
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
                                                color: Colors.grey[600],
                                              );
                                            },
                                          ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Profile Info Card
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
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
                              child: Column(
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
                                  _buildInfoRow(
                                    context,
                                    Icons.person,
                                    'Nama Lengkap',
                                    _userProfile!.name,
                                  ),
                                  _buildInfoRow(
                                    context,
                                    Icons.email,
                                    'Email',
                                    _userProfile!.email,
                                  ),
                                  _buildInfoRow(
                                    context,
                                    Icons.wc,
                                    'Jenis Kelamin',
                                    _userProfile!.jenisKelamin == 'L'
                                        ? 'Laki-laki'
                                        : (_userProfile!.jenisKelamin == 'P'
                                            ? 'Perempuan'
                                            : 'Tidak Tersedia'),
                                  ),
                                  _buildInfoRow(
                                    context,
                                    Icons.school,
                                    'Jurusan/Training',
                                    _userProfile!.trainingTitle ??
                                        'Tidak Tersedia',
                                  ),
                                  _buildInfoRow(
                                    context,
                                    Icons.group,
                                    'Batch Ke',
                                    _userProfile!.batchKe ?? 'Tidak Tersedia',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: ElevatedButton(
                                  onPressed: _showEditNameDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.loginButtonColor,
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
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
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
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Theme Toggle
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

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.historyBlueShape, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

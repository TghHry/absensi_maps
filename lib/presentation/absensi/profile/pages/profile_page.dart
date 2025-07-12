// lib/presentation/absensi/profile/pages/profile_page.dart

import 'dart:convert'; // Tambahkan ini untuk base64Encode
import 'package:absensi_maps/models/profile_model.dart';
import 'package:absensi_maps/presentation/absensi/profile/services/profile_service.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:absensi_maps/api/api_service.dart';
import 'package:absensi_maps/models/user_model.dart';
import 'package:absensi_maps/models/session_manager.dart';
import 'package:image_picker/image_picker.dart'; // Tambahkan ini

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
  final SessionManager _sessionManager = SessionManager();
  final ImagePicker _picker = ImagePicker(); // Inisialisasi ImagePicker

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

    await _sessionManager.clearSession();
    debugPrint(
      'SessionManager dibersihkan (SharedPreferences & SecureStorage).',
    );

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
        const SnackBar(
          content: Text('Profil belum dimuat atau terjadi kesalahan.'),
        ),
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
                        _updateProfileOnServer(newName);
                      },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfileOnServer(String newName) async {
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

      final ProfileResponse response = await _profileService.updateProfileData(
        token,
        name: newName,
      );

      if (!mounted) return;

      if (response.data != null) {
        final User? oldUserFromSession = await _sessionManager.getUser();

        if (oldUserFromSession == null) {
          throw Exception('Sesi pengguna tidak valid saat memperbarui profil.');
        }

        final DateTime userCreatedAt =
            response.data!.createdAt ?? oldUserFromSession.createdAt;
        final DateTime userUpdatedAt =
            response.data!.updatedAt ?? oldUserFromSession.updatedAt;

        final User mergedUser = User(
          id: oldUserFromSession.id,
          name: response.data!.name,
          email: response.data!.email,
          emailVerifiedAt: oldUserFromSession.emailVerifiedAt,
          createdAt: userCreatedAt,
          updatedAt: userUpdatedAt,
          batchId: oldUserFromSession.batchId,
          trainingId: oldUserFromSession.trainingId,
          jenisKelamin: oldUserFromSession.jenisKelamin,
          profilePhotoPath: oldUserFromSession.profilePhotoPath,
          onesignalPlayerId: oldUserFromSession.onesignalPlayerId,
          batch: oldUserFromSession.batch,
          training: oldUserFromSession.training,
        );

        await _sessionManager.saveUser(mergedUser);

        setState(() {
          _userProfile = ProfileUser(
            id: mergedUser.id,
            name: mergedUser.name,
            email: mergedUser.email,
            emailVerifiedAt: mergedUser.emailVerifiedAt,
            createdAt: mergedUser.createdAt,
            updatedAt: mergedUser.updatedAt,
            batchId: mergedUser.batchId,
            trainingId: mergedUser.trainingId,
            jenisKelamin: mergedUser.jenisKelamin,
            profilePhoto: mergedUser.profilePhotoPath,
            onesignalPlayerId: mergedUser.onesignalPlayerId,
            batch: mergedUser.batch,
            training: mergedUser.training,
          );
        });

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
      debugPrint('Update profile failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan perubahan: ${e.toString().replaceFirst('Exception: ', '')}',
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

  // MENAMBAHKAN FUNGSI _changePhoto KEMBALI
  Future<void> _changePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);

      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final token = await ApiService.getToken();
        if (token == null) {
          throw Exception('Token tidak ditemukan');
        }

        final result = await ApiService.updateProfilePhoto(
          token: token,
          base64Photo: base64Image,
        );

        if (mounted) {
          if (result['message'] != null &&
              result['message'].contains('berhasil diperbarui')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
            );
            await _fetchUserProfile(); // Muat ulang data untuk refresh foto dan data lainnya
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Gagal update foto.'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Terjadi kesalahan saat mengupdate foto: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      debugPrint('Pemilihan foto dibatalkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Widget bodyContent;

    if (_isLoading && _userProfile == null && _errorMessage == null) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_userProfile == null) {
      bodyContent = const Center(
        child: Text('Tidak ada data profil ditemukan.'),
      );
    } else {
      bodyContent = RefreshIndicator(
        onRefresh: _fetchUserProfile,
        color: AppColors.homeTopBlue,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const SizedBox(width: 48)],
                ),
              ),
              const SizedBox(height: 20),
              // Avatar User dengan GestureDetector untuk _changePhoto
              GestureDetector(
                onTap:
                    _changePhoto, // Panggil _changePhoto saat area foto diklik
                child: Column(
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
                        // Menggunakan _userProfile?.fullProfilePhotoUrl untuk keamanan
                        child:
                            (_userProfile!.fullProfilePhotoUrl != null &&
                                    _userProfile!
                                        .fullProfilePhotoUrl!
                                        .isNotEmpty)
                                ? Image.network(
                                  _userProfile!
                                      .fullProfilePhotoUrl!, // Gunakan getter baru
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
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
                                  errorBuilder: (context, error, stackTrace) {
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
                    const SizedBox(
                      height: 10,
                    ), // Spasi antara avatar dan tombol
                    TextButton.icon(
                      icon: const Icon(Icons.photo_camera, size: 18),
                      label: const Text("Ubah Foto"),
                      onPressed: _changePhoto, // Panggil _changePhoto
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textDark, // Warna teks
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ), // Spasi antara area foto/tombol dan card info
              // Profile Info Card
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
                child: Column(
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
                      _userProfile!.trainingTitle ?? 'Tidak Tersedia',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: _showEditNameDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.loginButtonColor,
                      foregroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 15),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: _performLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Logout', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/dashboard.jpg', // Path ke gambar Anda
              fit: BoxFit.cover, // Menutupi seluruh area
            ),
          ),

          // Overlay Gelap untuk membuat teks/tombol mudah dibaca
          // Positioned.fill(
          //   child: Container(
          //     color: Colors.black.withOpacity(
          //       0.2,
          //     ), // Sesuaikan opacity sesuai kebutuhan
          //   ),
          // ),

          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: screenHeight * 0.35,
          //     color: AppColors.homeTopYellow,
          //   ),
          // ),
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: ClipPath(
          //     clipper: _ProfileBlueClipper(screenWidth, screenHeight * 0.35),
          //     child: Container(
          //       height: screenHeight * 0.35,
          //       color: AppColors.homeTopBlue,
          //     ),
          //   ),
          // ),
          Positioned.fill(child: bodyContent),
         
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

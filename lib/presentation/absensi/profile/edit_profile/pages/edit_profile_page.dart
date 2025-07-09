// File: lib/presentation/absensi/profile/pages/edit_profile_page.dart

import 'package:absensi_maps/presentation/absensi/auth/register/pages/registration_dropdown_data.dart';
import 'package:absensi_maps/presentation/absensi/profile/models/profile_model.dart';
import 'package:absensi_maps/presentation/absensi/profile/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan data lokal yang diupdate


class EditProfilePage extends StatefulWidget {
  final ProfileUser currentUser; // UBAH TIPE INI menjadi ProfileUser

  const EditProfilePage({super.key, required this.currentUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedJenisKelaminDisplay; // Untuk dropdown Jenis Kelamin yang sudah ada
  String? _selectedJenisKelaminValue;

  bool _isLoading = false;
  final ProfileService _profileService = ProfileService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentUser.name;
    _emailController.text = widget.currentUser.email;

    // Inisialisasi jenis kelamin dari profil yang ada
    if (widget.currentUser.jenisKelamin != null) {
      _selectedJenisKelaminValue = widget.currentUser.jenisKelamin;
      _selectedJenisKelaminDisplay = kJenisKelaminOptions
          .firstWhere((opt) => opt['value'] == _selectedJenisKelaminValue)['display'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSaveChanges() async {
    final String newName = _nameController.text.trim();
    final String newEmail = _emailController.text.trim();
    // String? newJenisKelamin = _selectedJenisKelaminValue; // Ambil dari dropdown

    if (newName.isEmpty || newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Email tidak boleh kosong.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Token otentikasi tidak ditemukan. Mohon login kembali.');
      }

      // Panggil service untuk memperbarui profil (hanya kirim name dan email)
      // Jika API mendukung update jenis kelamin, Anda bisa menambahkannya di sini
      final EditProfileResponse response = await _profileService.updateUserProfile(
        newName,
        newEmail,
        // (opsional) jenisKelamin: newJenisKelamin,
      );

      // Perbarui data di SharedPreferences (jika ada) dan kembalikan ke ProfilePage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', response.data.name);
      await prefs.setString('user_email', response.data.email);
      // Jika Anda menyimpan data lain seperti jenis kelamin di SP, perbarui juga
      // await prefs.setString('user_jenis_kelamin', response.data.jenisKelamin ?? '');


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.green),
      );

      // Kirim kembali objek ProfileUser yang diupdate ke halaman profil
      Navigator.of(context).pop(response.data);

    } catch (e) {
      debugPrint('Save profile changes failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan perubahan: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: AppColors.historyBlueShape,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Pribadi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            // Dropdown untuk Jenis Kelamin
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Jenis Kelamin',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              value: _selectedJenisKelaminDisplay,
              hint: const Text('Pilih Jenis Kelamin'),
              items: kJenisKelaminOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option['display'],
                  child: Text(option['display']!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedJenisKelaminDisplay = newValue;
                  _selectedJenisKelaminValue = kJenisKelaminOptions
                      .firstWhere((opt) => opt['display'] == newValue)['value'];
                });
              },
              validator: (value) => value == null ? 'Jenis kelamin wajib dipilih.' : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSaveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loginButtonColor,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
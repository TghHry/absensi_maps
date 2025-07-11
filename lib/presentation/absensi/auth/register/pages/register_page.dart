// lib/presentation/absensi/auth/register/pages/register_page.dart

import 'package:absensi_maps/presentation/absensi/auth/register/pages/registration_dropdown_data.dart';
import 'package:flutter/material.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint

import 'package:absensi_maps/api/api_service.dart';
import 'package:absensi_maps/models/training_model.dart'; // Untuk Datum (Training)
import 'package:absensi_maps/models/batch_model.dart'; // Untuk BatchData (Batch)


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>(); // Untuk validasi form

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Datum? _selectedTraining; // Objek Datum (training) yang dipilih
  BatchData? _selectedBatch; // Objek BatchData (batch) yang dipilih
  String? _selectedJenisKelaminValue; // 'L' atau 'P'

  bool _obscureText = true;
  bool _isLoading = false;

  // Data hardcoded untuk dropdown (seperti yang diminta)
  // List<Datum> _trainings = []; // Tidak lagi perlu jika hardcode
  // List<BatchData> _batches = []; // Tidak lagi perlu jika hardcode

  final List<Map<String, String>> _jenisKelaminOptions = kJenisKelaminOptions; // Dari data hardcoded

  @override
  void initState() {
    super.initState();
    // Tidak perlu memanggil _fetchDropdownData karena data sudah hardcoded
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _onRegisterButtonPressed() async {
    if (!_formKey.currentState!.validate()) { // Memastikan semua field di form valid
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua kolom yang wajib diisi dengan benar.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    
    // Validasi tambahan untuk dropdowns
    if (_selectedTraining == null || _selectedBatch == null || _selectedJenisKelaminValue == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih Jurusan/Training, Batch, dan Jenis Kelamin.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Ambil ID dari objek yang dipilih
    final int trainingId = _selectedTraining!.id;
    final int batchId = _selectedBatch!.id; // Pastikan id di BatchData tidak null
    final String jenisKelamin = _selectedJenisKelaminValue!;

    setState(() {
      _isLoading = true; // Tampilkan loading untuk proses registrasi
    });

    try {
      final Map<String, dynamic> apiResponse = await ApiService.register(
        name: name,
        email: email,
        password: password,
        jenisKelamin: jenisKelamin,
        trainingId: trainingId,
        batchId: batchId,
        profilePhoto: null, // Jika ada fitur upload foto, ini bisa diisi
      );

      if (!mounted) return;

      final String? message = apiResponse['message'] as String?;
      final bool success = apiResponse['success'] == true || (message != null && message.toLowerCase().contains('berhasil'));

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? 'Registrasi berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya (Login)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? 'Registrasi gagal. Silakan coba lagi.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('Registrasi gagal: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registrasi gagal: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                color: AppColors.loginAccentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buat Akun Baru',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Daftar untuk membuat akun Anda',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textLight.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 0.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: AppColors.loginCardColor,
                    elevation: 3,
                    child: Form( // Menggunakan Form untuk validasi
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Lengkap',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama tidak boleh kosong.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email tidak boleh kosong.';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Masukkan email yang valid.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password tidak boleh kosong.';
                                }
                                if (value.length < 6) {
                                  return 'Password minimal 6 karakter.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            // --- Dropdown untuk JENIS_KELAMIN (dari data hardcoded) ---
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Jenis Kelamin',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              isExpanded: true,
                              value: _selectedJenisKelaminValue,
                              hint: const Text('Pilih Jenis Kelamin'),
                              items: _jenisKelaminOptions.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option['value'],
                                  child: Text(option['display']!),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedJenisKelaminValue = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Jenis kelamin wajib dipilih.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            // --- Dropdown untuk JURUSAN/TRAINING (dari data hardcoded) ---
                            DropdownButtonFormField<Datum>(
                                        decoration: const InputDecoration(
                                          labelText: 'Jurusan/Training',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        isExpanded: true,
                                        value: _selectedTraining,
                                        hint: const Text('Pilih Jurusan/Training'),
                                        items: kTrainingOptions.map((training) {
                                          return DropdownMenuItem<Datum>(
                                            value: training,
                                            child: Text(training.title ?? 'Tidak diketahui'),
                                          );
                                        }).toList(),
                                        onChanged: (Datum? newValue) {
                                          setState(() {
                                            _selectedTraining = newValue;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Jurusan wajib dipilih.';
                                          }
                                          return null;
                                        },
                                      ),
                            const SizedBox(height: 15),
                            // --- Dropdown untuk BATCH (dari data hardcoded) ---
                            DropdownButtonFormField<BatchData>(
                                        decoration: const InputDecoration(
                                          labelText: 'Batch',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        isExpanded: true,
                                        value: _selectedBatch,
                                        hint: const Text('Pilih Batch'),
                                        items: kBatchOptions.map((batch) {
                                          return DropdownMenuItem<BatchData>(
                                            value: batch,
                                            child: Text(batch.batchKe ?? 'Tidak diketahui'),
                                          );
                                        }).toList(),
                                        onChanged: (BatchData? newValue) {
                                          setState(() {
                                            _selectedBatch = newValue;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Batch wajib dipilih.';
                                          }
                                          return null;
                                        },
                                      ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : _onRegisterButtonPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.loginButtonColor,
                                  foregroundColor: AppColors.textLight,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Daftar',
                                        style: TextStyle(fontSize: 18),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Belum punya akun?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
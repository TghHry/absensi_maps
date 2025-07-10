// File: lib/presentation/absensi/profile/pages/edit_profile_page.dart

import 'package:absensi_maps/models/profile_model.dart';
import 'package:absensi_maps/presentation/absensi/auth/register/pages/registration_dropdown_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

// Import ApiService dan model-model terkait
import 'package:absensi_maps/api/api_service.dart'; // Untuk ApiService.tokenKey
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:absensi_maps/presentation/absensi/profile/services/profile_service.dart'; // ProfileService
import 'package:absensi_maps/models/training_model.dart'; // Datum
import 'package:absensi_maps/models/batch_model.dart'; // BatchData

class EditProfilePage extends StatefulWidget {
  final ProfileUser currentUser; // UBAH TIPE INI menjadi ProfileUser

  const EditProfilePage({super.key, required this.currentUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>(); // Tambahkan FormKey untuk validasi

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedJenisKelaminDisplay; // Untuk tampilan dropdown Jenis Kelamin
  String?
  _selectedJenisKelaminValue; // Untuk nilai yang dikirim ke API ('L' / 'P')

  Datum? _selectedTraining; // Objek Datum yang dipilih
  BatchData? _selectedBatch; // Objek BatchData yang dipilih

  List<Datum> _trainings = [];
  List<BatchData> _batches = [];

  bool _isLoading = false;
  bool _isDropdownDataLoading = true; // State untuk loading data dropdown
  String? _dropdownErrorMessage;

  final ProfileService _profileService = ProfileService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // ----- PERBAIKAN: GUNAKAN widget.currentUser -----
    _nameController.text = widget.currentUser.name;
    _emailController.text = widget.currentUser.email;

    // Inisialisasi jenis kelamin dari profil yang ada
    if (widget.currentUser.jenisKelamin != null) {
      _selectedJenisKelaminValue = widget.currentUser.jenisKelamin;
      _selectedJenisKelaminDisplay =
          kJenisKelaminOptions.firstWhere(
            (opt) => opt['value'] == _selectedJenisKelaminValue,
          )['display'];
    }

    _fetchDropdownDataAndSetInitialValues(); // Panggil ini untuk ambil data & set nilai awal
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchDropdownDataAndSetInitialValues() async {
    setState(() {
      _isDropdownDataLoading = true;
      _dropdownErrorMessage = null;
    });

    try {
      // Ambil data training dan batch dari API
      final ListJurusan trainingsResponse = await ApiService.getTrainings();
      final BatchResponse batchesResponse = await ApiService.getBatches();

      if (!mounted) return;

      setState(() {
        _trainings = trainingsResponse.data;
        _batches = batchesResponse.data ?? [];

        // Set nilai awal untuk dropdown Training
        if (widget.currentUser.trainingId != null && _trainings.isNotEmpty) {
          _selectedTraining = _trainings.firstWhereOrNull(
            (t) => t.id == widget.currentUser.trainingId,
          );
        }

        // Set nilai awal untuk dropdown Batch
        if (widget.currentUser.batchId != null && _batches.isNotEmpty) {
          _selectedBatch = _batches.firstWhereOrNull(
            (b) => b.id == widget.currentUser.batchId,
          );
        }
      });
    } catch (e) {
      debugPrint('Error fetching dropdown data: $e');
      if (!mounted) return;
      setState(() {
        _dropdownErrorMessage =
            'Gagal memuat pilihan data: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isDropdownDataLoading = false;
      });
    }
  }

  Future<void> _onSaveChanges() async {
    if (!_formKey.currentState!.validate()) {
      // Validasi form
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua kolom yang wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String newName = _nameController.text.trim();
    // final String newEmail = _emailController.text.trim(); // Email tidak dikirim untuk update profile API ini
    final String? newJenisKelamin =
        _selectedJenisKelaminValue; // Ambil dari dropdown
    final int? newTrainingId = _selectedTraining?.id;
    final int? newBatchId = _selectedBatch?.id;

    // Tambahan validasi untuk dropdown
    if (newJenisKelamin == null ||
        newTrainingId == null ||
        newBatchId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon lengkapi pilihan Jenis Kelamin, Jurusan/Training, dan Batch.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String? token =
          await ApiService.getToken(); // Menggunakan ApiService.getToken()
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      // Panggil service untuk memperbarui profil
      final ProfileResponse response = await _profileService.updateProfileData(
        token,
        name: newName,
        jenisKelamin: newJenisKelamin,
        trainingId: newTrainingId,
        batchId: newBatchId,
      );

      if (!mounted) return;

      // Periksa apakah update berhasil
      if (response.data != null) {
        // Perbarui data di SharedPreferences (jika ada) dan kembalikan ke ProfilePage
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', response.data!.name);
        await prefs.setString(
          'user_email',
          response.data!.email,
        ); // Asumsi email bisa diupdate
        await prefs.setString(
          'user_jenis_kelamin',
          response.data!.jenisKelamin ?? '',
        );
        // Perbarui training_id dan batch_id di SharedPreferences jika Anda menyimpannya
        if (response.data!.trainingId != null)
          prefs.setInt('user_training_id', response.data!.trainingId!);
        if (response.data!.batchId != null)
          prefs.setInt('user_batch_id', response.data!.batchId!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // Kirim kembali objek ProfileUser yang diupdate ke halaman profil
        Navigator.of(context).pop(response.data);
      } else {
        // Jika response.data null tapi message ada (misal: "data tidak berubah")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Save profile changes failed: $e');
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
        child: Form(
          // Wrap with Form for validation
          key: _formKey,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong.';
                  }
                  return null;
                },
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
                readOnly: true, // Email biasanya tidak bisa diubah dari sini
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
                items:
                    kJenisKelaminOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['display'], // Tampilkan display
                        child: Text(option['display']!),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedJenisKelaminDisplay = newValue;
                    _selectedJenisKelaminValue =
                        kJenisKelaminOptions.firstWhere(
                          (opt) => opt['display'] == newValue,
                        )['value'];
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Jenis kelamin wajib dipilih.' : null,
              ),
              const SizedBox(height: 20),
              // Dropdown untuk Jurusan/Training
              _isDropdownDataLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _dropdownErrorMessage != null
                  ? Text(
                    _dropdownErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                  )
                  : DropdownButtonFormField<Datum>(
                    decoration: const InputDecoration(
                      labelText: 'Jurusan/Training',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: _selectedTraining,
                    hint: const Text('Pilih Jurusan/Training'),
                    items:
                        _trainings.map((training) {
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
                    validator:
                        (value) =>
                            value == null ? 'Jurusan wajib dipilih.' : null,
                  ),
              const SizedBox(height: 20),
              // Dropdown untuk Batch
              _isDropdownDataLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _dropdownErrorMessage != null
                  ? const SizedBox.shrink()
                  : DropdownButtonFormField<BatchData>(
                    decoration: const InputDecoration(
                      labelText: 'Batch',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: _selectedBatch,
                    hint: const Text('Pilih Batch'),
                    items:
                        _batches.map((batch) {
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
                    validator:
                        (value) =>
                            value == null ? 'Batch wajib dipilih.' : null,
                  ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading || _isDropdownDataLoading
                          ? null
                          : _onSaveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.loginButtonColor,
                    foregroundColor: AppColors.textLight,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading
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
      ),
    );
  }
}

// Extension untuk List agar punya firstWhereOrNull
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

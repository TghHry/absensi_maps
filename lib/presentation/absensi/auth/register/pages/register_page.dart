import 'package:absensi_maps/presentation/absensi/auth/register/pages/registration_dropdown_data.dart';
import 'package:flutter/material.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:absensi_maps/presentation/absensi/auth/register/services/register_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _batchIdController = TextEditingController();

  String? _selectedTrainingId;
  String? _selectedJenisKelaminDisplay;
  String? _selectedJenisKelaminValue;

  final RegisterService _registerService = RegisterService();

  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _batchIdController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _onRegisterButtonPressed() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String batchId = _batchIdController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        batchId.isEmpty ||
        _selectedTrainingId == null ||
        _selectedJenisKelaminValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua kolom yang wajib diisi.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final registrationResponse = await _registerService.registerUser(
        name,
        email,
        password,
        batchId,
        _selectedTrainingId!,
        _selectedJenisKelaminValue!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(registrationResponse.message),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.1),
                  topRight: Radius.circular(screenWidth * 0.1),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.15),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buat Akun Baru',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Daftar untuk membuat akun Anda',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: AppColors.textLight.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: AppColors.loginCardColor,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'No. Hp',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // --- Input untuk BATCH ID (sebagai TextField) ---
                          TextFormField(
                            controller: _batchIdController,
                            decoration: const InputDecoration(
                              labelText: 'ID Batch',
                              hintText: 'Masukkan ID Batch',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          // --- Dropdown untuk TRAINING_ID ---
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Jurusan/Training',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedTrainingId,
                            hint: const Text('Pilih Jurusan/Training'),
                            // PENTING: selectedItemBuilder untuk teks yang ditampilkan di field tertutup
                            selectedItemBuilder: (BuildContext context) {
                              return kTrainingOptions.map((training) {
                                return Text(
                                  training.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                );
                              }).toList();
                            },
                            items:
                                kTrainingOptions.map((training) {
                                  return DropdownMenuItem<String>(
                                    value: training.id.toString(),
                                    // Untuk item di daftar menu yang terbuka, cukup Text saja
                                    // Tidak perlu Row atau Expanded di sini
                                    child: Text(
                                      training.title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedTrainingId = newValue;
                              });
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Jurusan wajib dipilih.'
                                        : null,
                          ),
                          const SizedBox(height: 20),
                          // --- Dropdown untuk JENIS_KELAMIN ---
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Jenis Kelamin',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedJenisKelaminDisplay,
                            hint: const Text('Pilih Jenis Kelamin'),
                            items:
                                kJenisKelaminOptions.map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option['display'],
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
                                    value == null
                                        ? 'Jenis kelamin wajib dipilih.'
                                        : null,
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
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'Register',
                                        style: TextStyle(fontSize: 18),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Sudah punya akun?"),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// lib/presentation/absensi/auth/login/login_page.dart

import 'package:flutter/material.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:absensi_maps/presentation/absensi/auth/login/models/login_model.dart';
import 'package:absensi_maps/presentation/absensi/auth/login/services/login_service.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  final LoginService _loginService = LoginService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Mengubah visibilitas teks password.
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  /// Memuat email yang diingat dari SharedPreferences saat inisialisasi.
  Future<void> _loadRememberedEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rememberedEmail = prefs.getString('remembered_email');
    if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = rememberedEmail;
        _rememberMe = true; // Otomatis centang "Ingat saya" jika email ditemukan
      });
    }
  }

  /// Fungsi yang dipanggil saat tombol Login ditekan.
  void _onLoginButtonPressed() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Validasi sederhana input.
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password tidak boleh kosong.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Tampilkan indikator loading
    });

    try {
      // Memanggil layanan login untuk otentikasi pengguna.
      final LoginResponse response = await _loginService.loginUser(email, password);

      // Jika login berhasil, simpan token dan data pengguna.
      if (response.token != null && response.data != null) {
        await _saveLoginData(response.data!); // Pastikan data tidak null sebelum disimpan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        // Navigasi ke halaman utama dan hapus semua rute sebelumnya.
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main', // Pastikan rute ini terdaftar di MaterialApp Anda
          (Route<dynamic> route) => false,
        );
      } else {
        // Handle kasus di mana token atau data null meskipun response sukses.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Login berhasil, namun data tidak lengkap.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Tangani error yang terjadi selama proses login.
      debugPrint('Error saat login: $e'); // Menggunakan debugPrint untuk logging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: ${e.toString().contains('Failed host lookup') ? 'Tidak ada koneksi internet.' : e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Sembunyikan indikator loading
      });
    }
  }

  /// Menyimpan token autentikasi ke FlutterSecureStorage dan data pengguna ke SharedPreferences.
  Future<void> _saveLoginData(LoginData data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Simpan token menggunakan FlutterSecureStorage (terenkripsi dan aman).
    await _secureStorage.write(key: 'auth_token', value: data.token);
    debugPrint('Token disimpan dengan aman.');

    // Simpan data pengguna (id, name, email) menggunakan SharedPreferences.
    await prefs.setInt('user_id', data.user.id);
    await prefs.setString('user_name', data.user.name);
    await prefs.setString('user_email', data.user.email);
    debugPrint('Data pengguna disimpan di SharedPreferences.');

    // Simpan email untuk fitur "Ingat saya" jika dicentang.
    if (_rememberMe) {
      await prefs.setString('remembered_email', data.user.email);
      debugPrint('Email diingat: ${data.user.email}');
    } else {
      await prefs.remove('remembered_email'); // Hapus jika tidak dicentang
      debugPrint('Email tidak diingat, data dihapus dari SharedPreferences.');
    }
  }

  /// Fungsi yang dipanggil saat tombol Lupa Password ditekan.
  void _onForgotPasswordPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda menekan Lupa Password!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushNamed(
      context,
      '/password', // Pastikan rute ini terdaftar di MaterialApp Anda
    );
  }

  /// Fungsi yang dipanggil saat tombol Daftar ditekan.
  void _onSignUpPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda menekan Daftar!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushNamed(
      context,
      '/register', // Pastikan rute ini terdaftar di MaterialApp Anda
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundColor,
      body: Stack(
        children: [
          // Bagian bawah berwarna aksen dengan radius melengkung
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                color: AppColors.loginAccentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.2),
                  topRight: Radius.circular(screenWidth * 0.2),
                ),
              ),
            ),
          ),
          // Konten utama halaman login
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.15),
                  // Judul dan sub-judul "Selamat Datang Kembali"
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang Kembali',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Silakan masuk ke akun Anda', // Lebih natural
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textLight.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  // Kartu input login
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: AppColors.loginCardColor,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TextFormField untuk Email
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
                          // TextFormField untuk Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Bagian "Ingat saya" dan "Lupa Password?"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        _rememberMe = newValue!;
                                      });
                                    },
                                  ),
                                  const Text('Ingat saya'),
                                ],
                              ),
                              TextButton(
                                onPressed: _onForgotPasswordPressed,
                                child: Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Tombol Login
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onLoginButtonPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.loginButtonColor,
                                foregroundColor: AppColors.textLight,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    ) // Tampilkan loading indicator
                                  : const Text(
                                      'Masuk', // Lebih umum dari 'Login'
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Teks "Belum punya akun?" dan tombol "Daftar"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Belum punya akun?"),
                              TextButton(
                                onPressed: _onSignUpPressed,
                                child: Text(
                                  'Daftar Sekarang', // Lebih lengkap
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
// lib/presentation/absensi/auth/login/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:absensi_maps/api/api_service.dart'; // PASTIKAN IMPORT INI BENAR
import 'package:absensi_maps/models/login_response_model.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:absensi_maps/models/session_manager.dart'; // <<< TAMBAHKAN IMPORT INI

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

  // Ganti _secureStorage jika SessionManager akan mengurus semua
  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SessionManager _sessionManager =
      SessionManager(); // <<< Inisialisasi SessionManager

  @override
  void initState() {
    super.initState();
    debugPrint('LoginPage: initState terpanggil.');
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _loadRememberedEmail() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? rememberedEmail = prefs.getString('remembered_email');
      if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
        setState(() {
          _emailController.text = rememberedEmail;
          _rememberMe = true;
        });
      }
      debugPrint('LoginPage: Remembered email dimuat: $rememberedEmail');
    } catch (e) {
      debugPrint('LoginPage: Error memuat remembered email: $e');
    }
  }

  void _onLoginButtonPressed() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    debugPrint('LoginPage: Tombol Login ditekan.');
    debugPrint('LoginPage: Mencoba login dengan email: $email');

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) {
        debugPrint('LoginPage: Widget tidak mounted saat validasi kosong.');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password tidak boleh kosong.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('LoginPage: Memulai panggilan ApiService.login.');
      // PASTIKAN PANGGILAN API INI SESUAI DENGAN API_SERVICE.DART
      final Map<String, dynamic> apiResponse = await ApiService.login(
        email,
        password,
      );
      debugPrint(
        'LoginPage: Panggilan ApiService.login selesai. Respon: $apiResponse',
      );

      final LoginResponse response = LoginResponse.fromJson(apiResponse);
      debugPrint('LoginPage: Respon API berhasil diparsing ke LoginResponse.');

      if (!mounted) {
        debugPrint(
          'LoginPage: Widget tidak mounted setelah login API, menghentikan eksekusi.',
        );
        return;
      }

      if (response.token != null && response.user != null) {
        debugPrint(
          'LoginPage: Token dan User ditemukan. Memulai _saveLoginData.',
        );
        // <<< PERBAIKAN: Gunakan SessionManager untuk menyimpan token dan user >>>
        await _sessionManager.saveToken(response.token!);
        await _sessionManager.saveUser(response.user!);
        // PENTING: Juga simpan remembered_email via SharedPreferences secara terpisah
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('remembered_email', response.user!.email);
          debugPrint(
            'LoginPage:_saveLoginData: Email diingat: ${response.user!.email}',
          );
        } else {
          await prefs.remove('remembered_email');
          debugPrint(
            'LoginPage:_saveLoginData: Email tidak diingat, data dihapus.',
          );
        }
        debugPrint(
          'LoginPage: _saveLoginData selesai.',
        ); // Ini log dari _saveLoginData yang sudah dihilangkan

        if (!mounted) {
          debugPrint(
            'LoginPage: Widget tidak mounted setelah _saveLoginData, menghentikan eksekusi.',
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint('LoginPage: SnackBar sukses ditampilkan.');

        if (!mounted) {
          debugPrint(
            'LoginPage: Widget tidak mounted sebelum navigasi, menghentikan eksekusi.',
          );
          return;
        }

        debugPrint(
          'LoginPage: Mencoba memanggil Navigator.pushNamedAndRemoveUntil ke /main.',
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main', // Pastikan rute '/main' terdaftar di main.dart Anda
          (Route<dynamic> route) => false,
        );
        debugPrint(
          'LoginPage: Navigator.pushNamedAndRemoveUntil selesai dieksekusi.',
        );
      } else {
        debugPrint('LoginPage: Login gagal (token atau user null).');
        if (!mounted) {
          debugPrint(
            'LoginPage: Widget tidak mounted saat menampilkan error login (gagal).',
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('LoginPage: SnackBar error ditampilkan.');
      }
    } catch (e) {
      debugPrint('LoginPage: ERROR umum saat login: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login gagal: ${e.toString().contains('Failed host lookup') ? 'Tidak ada koneksi internet.' : e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('LoginPage: Loading state diset false.');
      } else {
        debugPrint(
          'LoginPage: Widget tidak mounted, tidak bisa set loading state.',
        );
      }
    }
  }

  // Hapus _saveLoginData karena diganti oleh SessionManager
  // Future<void> _saveLoginData(String token, User user) async { ... }

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
      '/password',
    ); // Pastikan rute '/password' terdaftar
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
      '/register',
    ); // Pastikan rute '/register' terdaftar
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('LoginPage: build terpanggil.');
    final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width; // Tidak digunakan di sini, bisa dihapus jika tidak dipakai

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/auth.png', // Pastikan path gambar benar
              fit: BoxFit.cover,
            ),
          ),

          // Overlay Gelap untuk membuat teks/tombol mudah dibaca
          // Positioned.fill(
          //   child: Container(
          //     color: Colors.black.withOpacity(0.6),
          //   ),
          // ),
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
                            'Selamat Datang Kembali',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Silakan masuk ke akun Anda',
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
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock),
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
                          const SizedBox(height: 10),
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _onLoginButtonPressed,
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
                                        'Masuk',
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
                                onPressed: _onSignUpPressed,
                                child: Text(
                                  'Daftar di sini',
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

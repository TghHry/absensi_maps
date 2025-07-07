import 'package:flutter/material.dart';
import 'package:absensi_maps/utils/app_colors.dart'; // Pastikan ini sudah ada dan berisi warna custom Anda

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Hanya controller untuk UI, tanpa validasi atau integrasiNotifier
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true; // State lokal untuk visibility password
  bool _rememberMe = false; // State lokal untuk "Remember me"

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    // Cukup update state lokal untuk UI
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Fungsi placeholder untuk tombol Login, hanya menampilkan snackbar
  void _onLoginButtonPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Login ditekan! Username: ${_usernameController.text}, Password: ${_passwordController.text}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main', // Nama rute untuk MainScreen Anda
      (Route<dynamic> route) =>
          false, // Ini akan menghapus semua rute sebelumnya
    );
  }

  // Fungsi placeholder untuk tombol Forgot Password
  void _onForgotPasswordPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lupa Password ditekan!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushNamed(
      context,
      '/password',
    ); // TODO: Nanti akan diganti dengan navigasi atau panggilan logika login
  }

  // Fungsi placeholder untuk tombol Sign Up
  void _onSignUpPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sign Up ditekan!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushNamed(
      context,
      '/register',
    ); // TODO: Nanti akan diganti dengan navigasi atau panggilan logika login
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Mengatur warna latar belakang sesuai desain
      backgroundColor: AppColors.loginBackgroundColor,
      body: Stack(
        children: [
          // Bagian kuning di bawah, dengan bentuk melengkung
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.4, // Ketinggian relatif
              decoration: BoxDecoration(
                color: AppColors.loginAccentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.2),
                  topRight: Radius.circular(screenWidth * 0.2),
                ),
              ),
            ),
          ),
          // Konten Utama: Teks "Welcome Back" dan Card Form Login
          Positioned.fill(
            child: SingleChildScrollView(
              // Agar bisa di-scroll jika keyboard muncul
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Spacer untuk posisi teks "Welcome Back"
                  SizedBox(height: screenHeight * 0.15),
                  // Teks "Welcome Back" dan "Login to your account"
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                      ), // Padding sesuai gambar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Login to your account',
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
                  // Jarak antara teks dan card
                  SizedBox(height: screenHeight * 0.05),
                  // Card untuk form login
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Sudut membulat pada card
                    ),
                    color: AppColors.loginCardColor,
                    elevation: 5, // Sedikit bayangan untuk efek 3D
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // Agar card menyesuaikan konten
                        children: [
                          // TextFormField untuk Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(), // Border kotak
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // TextFormField untuk Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText, // Kontrol visibility
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
                                onPressed:
                                    _togglePasswordVisibility, // Toggle visibility
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // "Remember me" dan "Forgot Password"
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
                                  const Text('Remember me'),
                                ],
                              ),
                              TextButton(
                                onPressed: _onForgotPasswordPressed,
                                child: Text(
                                  'Forgot Password',
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
                              onPressed: _onLoginButtonPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.loginButtonColor,
                                foregroundColor: AppColors.textLight,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ), // Sudut tombol
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // "Don't have account? Sign Up"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have account?"),
                              TextButton(
                                onPressed: _onSignUpPressed,
                                child: Text(
                                  'Sign Up',
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

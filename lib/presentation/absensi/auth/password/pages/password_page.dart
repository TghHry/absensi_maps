import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart'; // Pastikan ini sudah ada

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State lokal untuk visibility password (untuk kedua field)
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  // Fungsi placeholder untuk tombol "Create"
  void _onCreateButtonPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Create Password ditekan! (UI saja) Password: ${_passwordController.text}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pushNamed(context, '/');// TODO: Nanti akan diganti dengan logika reset password dan navigasi
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundColor, // Warna latar belakang abu-abu gelap
      body: Stack(
        children: [
          // Bagian kuning di bawah, dengan bentuk melengkung (sama seperti login/register)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.4, // Ketinggian relatif
              decoration: BoxDecoration(
                color: AppColors.loginAccentColor, // Warna kuning cerah
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.2),
                  topRight: Radius.circular(screenWidth * 0.2),
                ),
              ),
            ),
          ),
          // Konten Utama: Teks "New Password" dan Card Form
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Spacer untuk posisi teks "New Password"
                  SizedBox(height: screenHeight * 0.15),
                  // Teks "New Password"
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0), // Padding horizontal
                      child: Text(
                        'New Password', // Sesuai dengan desain gambar
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textLight, // Warna putih
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  // Jarak antara teks dan card
                  SizedBox(height: screenHeight * 0.05),
                  // Card untuk form password
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Sudut membulat pada card
                    ),
                    color: AppColors.loginCardColor, // Warna putih untuk card
                    elevation: 5, // Sedikit bayangan
                    child: Padding(
                      padding: const EdgeInsets.all(24.0), // Padding di dalam card
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Agar card menyesuaikan konten
                        children: [
                          // TextFormField untuk Kata Sandi (Password Baru)
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Kata Sandi',
                              border: const OutlineInputBorder(),
                              // Icon mata hanya ada di Konfirmasi Kata Sandi di gambar, jadi kita hilangkan di sini
                              suffixIcon: IconButton( // Tapi jika ingin tetap ada, bisa diaktifkan
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20), // Jarak antar TextFormField
                          // TextFormField untuk Konfirmasi Kata Sandi
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Kata Sandi',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey, // Warna icon mata
                                ),
                                onPressed: _toggleConfirmPasswordVisibility,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30), // Jarak ke tombol
                          // Tombol "Create"
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onCreateButtonPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.loginButtonColor, // Warna biru tombol
                                foregroundColor: AppColors.textLight, // Warna teks putih
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), // Sudut tombol
                                ),
                              ),
                              child: const Text(
                                'Create', // Sesuai dengan desain gambar
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
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
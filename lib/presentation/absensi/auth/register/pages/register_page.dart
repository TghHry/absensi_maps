import 'package:flutter/material.dart';
import 'package:absensi_maps/utils/app_colors.dart'; // Pastikan ini sudah ada dan berisi warna custom Anda
// import 'package:absensi_maps/presentation/absensi/auth/login/pages/login_page.dart'; // Untuk navigasi kembali ke Login

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Hanya controller untuk UI, tanpa validasi atau integrasiNotifier saat ini
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true; // State lokal untuk visibility password

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Fungsi placeholder untuk tombol Register, hanya menampilkan snackbar
  void _onRegisterButtonPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Register ditekan! (UI saja) Nama: ${_nameController.text}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          AppColors.loginBackgroundColor, // Warna latar belakang abu-abu gelap
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
                color: AppColors.loginAccentColor, // Warna kuning cerah
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    screenWidth * 0.2,
                  ), // Kurva di kiri atas
                  topRight: Radius.circular(
                    screenWidth * 0.2,
                  ), // Kurva di kanan atas
                ),
              ),
            ),
          ),
          // Konten Utama: Teks "Welcome Back" dan Card Form Register
          Positioned.fill(
            child: SingleChildScrollView(
              // Agar bisa di-scroll jika konten melebihi layar (misal keyboard muncul)
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Spacer untuk posisi teks "Welcome Back" agar tidak terlalu dekat atas
                  SizedBox(height: screenHeight * 0.15),
                  // Teks "Welcome Back" dan "Register to your account"
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                      ), // Padding horizontal sesuai gambar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back', // Sesuai dengan desain gambar
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textLight, // Warna putih
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Register to your account', // Sesuai dengan desain gambar
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: AppColors.textLight.withOpacity(
                                0.8,
                              ), // Warna putih transparan
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Jarak antara teks dan card
                  SizedBox(height: screenHeight * 0.05),
                  // Card untuk form registrasi
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Sudut membulat pada card
                    ),
                    color: AppColors.loginCardColor, // Warna putih untuk card
                    elevation: 5, // Sedikit bayangan untuk efek 3D
                    child: Padding(
                      padding: const EdgeInsets.all(
                        24.0,
                      ), // Padding di dalam card
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // Agar card menyesuaikan konten
                        children: [
                          // TextFormField untuk Nama
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama',
                              border: OutlineInputBorder(), // Border kotak
                              // Prefix icon tidak ada di gambar untuk Nama, No. Hp, Email
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ), // Jarak antar TextFormField
                          // TextFormField untuk No. Hp
                          TextFormField(
                            controller: _phoneController,
                            keyboardType:
                                TextInputType
                                    .phone, // Keyboard khusus nomor telepon
                            decoration: const InputDecoration(
                              labelText: 'No. Hp',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // TextFormField untuk Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType:
                                TextInputType
                                    .emailAddress, // Keyboard khusus email
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // TextFormField untuk Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText:
                                _obscureText, // Kontrol visibility teks password
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              // Di gambar ada icon mata di suffix
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey, // Warna icon mata
                                ),
                                onPressed:
                                    _togglePasswordVisibility, // Toggle visibility
                              ),
                            ),
                          ),
                          const SizedBox(height: 30), // Jarak ke tombol
                          // Tombol Register (di gambar tulisannya "Login", ini perlu disesuaikan)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onRegisterButtonPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors
                                        .loginButtonColor, // Warna biru tombol
                                foregroundColor:
                                    AppColors.textLight, // Warna teks putih
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
                                'Register', // Di gambar tertulis 'Login', kita ubah jadi 'Register'
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          // "Already have account? Login" (Tidak ada di gambar yang diberikan, tapi umum)
                          // Jika Anda ingin menambahkannya, bisa di sini
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  ); // Kembali ke halaman Login
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

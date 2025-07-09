import 'package:flutter/material.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Latar belakang hitam solid untuk tepi
      body: Stack(
        children: [
          // Gambar Latar Belakang
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/wallpaper.jpg', // Path ke gambar Anda
              fit: BoxFit.cover, // Menutupi seluruh area
            ),
          ),

          // Overlay Gelap untuk membuat teks/tombol mudah dibaca
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                0.6,
              ), // Sesuaikan opacity sesuai kebutuhan
            ),
          ),

          // Konten: Tombol dan Ikon Sosial
          Column(
            children: [
              // Spacer untuk mendorong konten ke bawah (sesuaikan sesuai kebutuhan)
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 30.0,
                ),
                child: Column(
                  children: <Widget>[
                    // Tombol MASUK (SIGN IN)
                    _buildSignInButton(),
                    const SizedBox(height: 16),
                    // Tombol DAFTAR (SIGN UP)
                    _buildSignUpButton(),
                    const SizedBox(height: 20),
                    // Lupa Kata Sandi?
                    TextButton(
                      onPressed: () {
                        // Tampilkan SnackBar untuk "Lupa Kata Sandi?" juga
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ditunggu untuk versi 2.0'),
                            backgroundColor: Colors.blueAccent,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        'Lupa Kata Sandi ?', // Diubah ke Bahasa Indonesia
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Ikon Media Sosial
                    // _buildSocialMediaIcons(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
       Navigator.pushNamed(context,'/login');  // Tangani Masuk (Sign In)
          print('Tombol MASUK Ditekan');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700), // Warna Kuning/Emas
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        icon: const Icon(Icons.login, color: Colors.black), // Ikon Login
        label: const Text(
          'MASUK', // Diubah ke Bahasa Indonesia
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context,'/register');
          print('Tombol DAFTAR Ditekan');
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFFFD700), // Border Kuning/Emas
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        icon: const Icon(
          Icons.person_add,
          color: Colors.white,
        ), // Ikon Daftar (Person Add)
        label: const Text(
          'DAFTAR', // Diubah ke Bahasa Indonesia
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget _buildSocialMediaIcons() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       _buildSocialIcon(FontAwesomeIcons.facebookF),
  //       const SizedBox(width: 20),
  //       _buildSocialIcon(FontAwesomeIcons.google),
  //       const SizedBox(width: 20),
  //       _buildSocialIcon(FontAwesomeIcons.xTwitter),
  //     ],
  //   );
  // }

  // Widget _buildSocialIcon(IconData iconData) {
  //   return Container(
  //     width: 50,
  //     height: 50,
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //       border: Border.all(
  //         color: Colors.white.withOpacity(
  //           0.5,
  //         ), // Border lebih terang untuk ikon sosial
  //         width: 1,
  //       ),
  //     ),
  //     child: IconButton(
  //       icon: Icon(iconData, color: Colors.white.withOpacity(0.7), size: 28),
  //       onPressed: () {
  //         // Tangani ketukan ikon media sosial dan tampilkan SnackBar
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Ditunggu untuk versi 2.0'),
  //             backgroundColor: Colors.blueAccent,
  //             duration: Duration(seconds: 2),
  //           ),
  //         );
  //         print('Ikon sosial ditekan: $iconData');
  //       },
  //     ),
  //   );
  // }
}

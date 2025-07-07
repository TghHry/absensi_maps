import 'package:absensi_maps/features/theme_provider.dart';
import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Untuk ThemeProvider

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // Untuk kebutuhan tema
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightBackground, // Background abu-abu muda
      body: Stack(
        children: [
          // Latar belakang kuning dan biru di bagian atas (mirip Home/History)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.35, // Ketinggian area atas
              color: AppColors.homeTopYellow, // Warna kuning
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _ProfileBlueClipper(
                screenWidth,
                screenHeight * 0.35,
              ), // Custom clipper untuk bentuk biru
              child: Container(
                height: screenHeight * 0.35,
                color: AppColors.homeTopBlue, // Warna biru
              ),
            ),
          ),
          // Konten utama halaman
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
            ), // Padding dari atas untuk header
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profil (Judul, Avatar, Nama, ID/Jabatan)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tombol back dan toggle tema
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        
                          // Judul "Profile" di tengah atau sedikit ke kanan agar Avatar dan teks bisa sejajar
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                            
                            ),
                          ),
                          // Tombol Logout/Settings
                          IconButton(
                            icon: const Icon(
                              Icons.exit_to_app,
                              color: AppColors.textLight,
                              size: 28,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Logout/Settings ditekan (UI saja)',
                                  ),
                                ),
                              );
                              Navigator.pushNamed(context, '/');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Jarak ke avatar
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Colors.white, // Background lingkaran putih
                                border: Border.all(
                                  color: AppColors.homeTopBlue,
                                  width: 3,
                                ), // Border biru
                              ),
                              child: ClipOval(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/edit_profile',
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/images/user_avatar.png', // Pastikan path ini benar
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey[600],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Mamat',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '12345678 - Junior UX Designer',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textLight.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Jarak ke card info
                // Konten Card Informasi
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                    color:
                        AppColors
                            .homeCardBackground, // Latar belakang card putih
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Sudut membulat card
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bagian Personal Information
                      Text(
                        'Personal Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildInfoRow(context, 'Nama', 'Mamat'),
                      _buildInfoRow(context, 'Email', 'mamat@gmail.com'),
                      _buildInfoRow(context, 'No. Hp', '+62 8218182902'),
                      const SizedBox(height: 25),
                      // Bagian Password
                      Text(
                        'Password',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ubah Kata Sandi ditekan (UI saja)',
                                ),
                              ),
                            );
                            // TODO: Nanti navigasi ke halaman ubah kata sandi
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.loginButtonColor, // Warna biru
                            foregroundColor:
                                AppColors.textLight, // Warna teks putih
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Ubah Kata Sandi',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Padding di bawah untuk BottomNav
              ],
            ),
          ),
          // Tombol toggle tema di pojok kanan atas, jika diinginkan di sini
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Posisi dari atas
            right: 10,
            child: IconButton(
              icon: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
      // BottomNavigationBar tidak lagi di sini, sudah dipindahkan ke MainScreen
    );
  }

  // Widget helper untuk baris informasi
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper untuk memotong bentuk biru di bagian atas (mirip History)
class _ProfileBlueClipper extends CustomClipper<Path> {
  final double screenWidth;
  final double clipHeight;

  _ProfileBlueClipper(this.screenWidth, this.clipHeight);

  @override
  Path getClip(Size size) {
    Path path = Path();
    // Gambar bentuk biru sesuai gambar profil
    // Ini mungkin perlu penyesuaian untuk mencocokkan bentuk profil yang sedikit berbeda
    path.lineTo(
      0,
      size.height * 0.7,
    ); // Mulai garis lurus dari kiri atas ke bawah
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 1.0, // Titik kontrol untuk lekukan
      size.width,
      size.height * 0.4, // Titik akhir lekukan menuju kanan atas
    );
    path.lineTo(size.width, 0); // Garis lurus ke kanan atas
    path.close(); // Tutup path

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

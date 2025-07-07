import 'package:absensi_maps/utils/app_colors.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Untuk ThemeProvider
// import 'package:absensi_maps/features/theme_provider.dart'; // ThemeProvider (jika Anda ingin menggunakan themeProvider di sini)

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers untuk input fields
  final TextEditingController _nameController = TextEditingController(
    text: 'Mamat',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'mamat@gmail.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+62 8218182902',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Fungsi placeholder untuk tombol "Done"
  void _onDoneButtonPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Perubahan disimpan! (UI Simulasi) Nama: ${_nameController.text}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context); // Kembali ke halaman sebelumnya (ProfilePage)
    // TODO: Nanti akan diganti dengan logika update profil
  }

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context); // Tidak digunakan langsung di sini
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Tinggi area header kuning-biru (tetap)
    final double headerBgHeight =
        screenHeight * 0.35; // Tinggi latar belakang kuning/biru

    // Ukuran avatar
    final double avatarSize = 120;

    // --- Perhitungan Posisi Baru ---
    // Posisi TOP avatar: Tetap seperti sebelumnya (sudah bagus)
    final double avatarTopPosition =
        MediaQuery.of(context).padding.top + 40; // 40dp dari bawah status bar

    // Jarak yang diinginkan antara bagian bawah avatar dan bagian atas card
    final double desiredGapBetweenAvatarAndCard =
        25; // Anda bisa sesuaikan nilai ini

    // Posisi TOP card: Dimulai setelah avatar, ditambah jarak yang diinginkan
    final double cardTopPosition =
        (avatarTopPosition + avatarSize) + desiredGapBetweenAvatarAndCard;

    // Padding atas di dalam card: Kembali ke padding standar karena avatar tidak menutupi lagi
    final double cardPaddingTop = 25.0; // Padding vertikal standar

    return Scaffold(
      backgroundColor: AppColors.lightBackground, // Background abu-abu muda
      body: Stack(
        children: [
          // Latar belakang kuning di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: headerBgHeight, // Ketinggian area atas
              color: AppColors.homeTopYellow, // Warna kuning
            ),
          ),
          // Latar belakang biru di bagian atas dengan bentuk diagonal
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _EditProfileBlueClipper(
                screenWidth,
              ), // Custom clipper untuk bentuk biru diagonal
              child: Container(
                height: headerBgHeight,
                color: AppColors.homeTopBlue, // Warna biru
              ),
            ),
          ),
          // Judul "Edit Profile", Tombol Back
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                10, // Tetap 10dp dari status bar (sudah bagus)
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.textLight,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  },
                ),
                Expanded(
                  child: Text(
                    'Edit Profile',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Placeholder untuk simetri, atau Anda bisa tambahkan tombol lain
                const SizedBox(width: 48), // Lebar icon button + padding
              ],
            ),
          ),
          // Avatar dengan Icon Kamera
          Positioned(
            top: avatarTopPosition, // Posisi TOP avatar yang sudah bagus
            left: screenWidth / 2 - (avatarSize / 2), // Tengah horizontal
            child: Stack(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // Background putih di balik avatar
                    border: Border.all(color: AppColors.homeTopBlue, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/user_avatar.png', // Pastikan path ini benar
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey[600],
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color:
                          AppColors
                              .homeTopBlue, // Warna biru untuk background kamera
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Card untuk Input Fields
          Positioned(
            top: cardTopPosition, // Posisi TOP card yang disesuaikan
            left: 0,
            right: 0,
            bottom: 0, // Sampai ke bawah
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: EdgeInsets.fromLTRB(
                20.0,
                cardPaddingTop, // Padding atas disesuaikan
                20.0,
                20.0, // <-- Mengurangi padding bawah kartu (dari 25.0 menjadi 15.0)
              ),
              decoration: BoxDecoration(
                color: AppColors.homeCardBackground, // Warna putih untuk card
                borderRadius: BorderRadius.circular(20), // Sudut membulat card
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                // Agar input bisa discroll jika keyboard muncul
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Nama
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Input Email
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
                    // Input No. Hp
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'No. Hp',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ), // <-- Mengurangi jarak sebelum tombol (dari 40 menjadi 30)
                    // Tombol Done
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onDoneButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.loginButtonColor,
                          foregroundColor: AppColors.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper untuk memotong bentuk biru diagonal di bagian atas
class _EditProfileBlueClipper extends CustomClipper<Path> {
  final double screenWidth;

  _EditProfileBlueClipper(this.screenWidth);

  @override
  Path getClip(Size size) {
    Path path = Path();
    // Gambar bentuk biru diagonal
    path.lineTo(
      0,
      size.height * 0.2,
    ); // Mulai garis lurus dari kiri atas ke bawah
    path.lineTo(size.width, size.height); // Garis diagonal ke kanan bawah
    path.lineTo(size.width, 0); // Garis lurus ke kanan atas
    path.close(); // Tutup path

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

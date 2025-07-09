
// import 'package:absensi_maps/presentation/absensi/auth/login/models/login_model.dart';
// import 'package:absensi_maps/presentation/absensi/auth/login/services/login_service.dart';
// import 'package:flutter/material.dart';
// import 'package:absensi_maps/utils/app_colors.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan data sederhana
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk menyimpan token secara aman

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   // Mengubah _usernameController menjadi _emailController karena API login menggunakan email
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool _obscureText = true; // State lokal untuk visibility password
//   bool _rememberMe = false; // State lokal untuk "Remember me"
//   bool _isLoading = false; // State untuk indikator loading

//   final LoginService _loginService = LoginService(); // Inisialisasi LoginService
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Inisialisasi Secure Storage

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _togglePasswordVisibility() {
//     setState(() {
//       _obscureText = !_obscureText;
//     });
//   }

//   // Fungsi untuk memproses tombol Login
//   void _onLoginButtonPressed() async {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text.trim();

//     // Validasi sederhana
//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Email dan password tidak boleh kosong.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true; // Tampilkan loading
//     });

//     try {
//       // Panggil metode loginUser dari LoginService
//       final LoginResponse response = await _loginService.loginUser(email, password);

//       // Jika login berhasil, simpan data
//       await _saveLoginData(response.data);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(response.message),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Navigasi ke halaman utama aplikasi dan hapus semua rute sebelumnya
//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         '/main', // Nama rute untuk MainScreen Anda
//         (Route<dynamic> route) => false, // Ini akan menghapus semua rute sebelumnya
//       );

//     } catch (e) {
//       // Jika terjadi error saat login
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Login gagal: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false; // Sembunyikan loading
//       });
//     }
//   }

//   // Fungsi untuk menyimpan data login
//   Future<void> _saveLoginData(LoginData data) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Simpan token menggunakan FlutterSecureStorage (terenkripsi)
//     await _secureStorage.write(key: 'auth_token', value: data.token);
//     debugPrint('Token disimpan dengan aman.');

//     // Simpan data pengguna (id, name, email) menggunakan SharedPreferences
//     await prefs.setInt('user_id', data.user.id);
//     await prefs.setString('user_name', data.user.name);
//     await prefs.setString('user_email', data.user.email);
//     debugPrint('Data pengguna disimpan di SharedPreferences.');

//     // Jika "Remember me" dicentang, Anda bisa menyimpan email untuk auto-fill di kemudian hari
//     if (_rememberMe) {
//       await prefs.setString('remembered_email', data.user.email);
//       debugPrint('Email diingat: ${data.user.email}');
//     } else {
//       await prefs.remove('remembered_email'); // Hapus jika tidak dicentang
//     }
//   }

//   // Fungsi placeholder untuk tombol Forgot Password
//   void _onForgotPasswordPressed() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Lupa Password ditekan!'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//     Navigator.pushNamed(
//       context,
//       '/password',
//     );
//   }

//   // Fungsi placeholder untuk tombol Sign Up
//   void _onSignUpPressed() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Sign Up ditekan!'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//     Navigator.pushNamed(
//       context,
//       '/register',
//     );
//   }

//   // Fungsi untuk mengisi email jika ada yang diingat
//   @override
//   void initState() {
//     super.initState();
//     _loadRememberedEmail();
//   }

//   Future<void> _loadRememberedEmail() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? rememberedEmail = prefs.getString('remembered_email');
//     if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
//       setState(() {
//         _emailController.text = rememberedEmail;
//         _rememberMe = true; // Set remember me true jika email ditemukan
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: AppColors.loginBackgroundColor,
//       body: Stack(
//         children: [
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: screenHeight * 0.4,
//               decoration: BoxDecoration(
//                 color: AppColors.loginAccentColor,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(screenWidth * 0.2),
//                   topRight: Radius.circular(screenWidth * 0.2),
//                 ),
//               ),
//             ),
//           ),
//           Positioned.fill(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   SizedBox(height: screenHeight * 0.15),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 20.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Selamat Datang Kembali', // Disesuaikan ke Bahasa Indonesia
//                             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                   color: AppColors.textLight,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Login ke akun Anda', // Disesuaikan ke Bahasa Indonesia
//                             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                   color: AppColors.textLight.withOpacity(0.8),
//                                 ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.05),
//                   Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 16.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     color: AppColors.loginCardColor,
//                     elevation: 5,
//                     child: Padding(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // TextFormField untuk Email (sebelumnya Username)
//                           TextFormField(
//                             controller: _emailController, // Menggunakan _emailController
//                             keyboardType: TextInputType.emailAddress, // Tipe keyboard email
//                             decoration: const InputDecoration(
//                               labelText: 'Email', // Label diubah menjadi Email
//                               border: OutlineInputBorder(),
//                               prefixIcon: Icon(Icons.email), // Icon email
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           // TextFormField untuk Password
//                           TextFormField(
//                             controller: _passwordController,
//                             obscureText: _obscureText,
//                             decoration: InputDecoration(
//                               labelText: 'Password',
//                               border: const OutlineInputBorder(),
//                               prefixIcon: const Icon(Icons.lock),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscureText ? Icons.visibility_off : Icons.visibility,
//                                 ),
//                                 onPressed: _togglePasswordVisibility,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           // "Remember me" dan "Forgot Password"
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Checkbox(
//                                     value: _rememberMe,
//                                     onChanged: (bool? newValue) {
//                                       setState(() {
//                                         _rememberMe = newValue!;
//                                       });
//                                     },
//                                   ),
//                                   const Text('Ingat saya'), // Disesuaikan ke Bahasa Indonesia
//                                 ],
//                               ),
//                               TextButton(
//                                 onPressed: _onForgotPasswordPressed,
//                                 child: Text(
//                                   'Lupa Password?', // Disesuaikan ke Bahasa Indonesia
//                                   style: TextStyle(
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                           // Tombol Login
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: _isLoading ? null : _onLoginButtonPressed, // Nonaktifkan tombol saat loading
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.loginButtonColor,
//                                 foregroundColor: AppColors.textLight,
//                                 padding: const EdgeInsets.symmetric(vertical: 15),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               child: _isLoading
//                                   ? const CircularProgressIndicator(
//                                       color: Colors.white,
//                                     ) // Tampilkan loading indicator
//                                   : const Text(
//                                       'Login',
//                                       style: TextStyle(fontSize: 18),
//                                     ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           // "Don't have account? Sign Up"
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Text("Belum punya akun?"), // Disesuaikan ke Bahasa Indonesia
//                               TextButton(
//                                 onPressed: _onSignUpPressed,
//                                 child: Text(
//                                   'Daftar', // Disesuaikan ke Bahasa Indonesia
//                                   style: TextStyle(
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
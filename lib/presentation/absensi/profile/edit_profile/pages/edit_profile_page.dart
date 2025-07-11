// // File: lib/presentation/absensi/profile/pages/edit_profile_page.dart

// import 'package:absensi_maps/models/profile_model.dart';
// // Hapus import 'package:absensi_maps/presentation/absensi/auth/register/pages/registration_dropdown_data.dart'; // Tidak lagi perlu jika tidak pakai kJenisKelaminOptions
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter/foundation.dart'; // For debugPrint

// // Import ApiService dan model-model terkait
// import 'package:absensi_maps/api/api_service.dart'; // Untuk ApiService.getToken()
// import 'package:absensi_maps/utils/app_colors.dart';
// import 'package:absensi_maps/presentation/absensi/profile/services/profile_service.dart'; // ProfileService
// // Hapus import model training dan batch jika tidak lagi digunakan (karena tidak ada dropdown dinamis)
// // import 'package:absensi_maps/models/training_model.dart'; // Datum
// // import 'package:absensi_maps/models/batch_model.dart'; // BatchData

// class EditProfilePage extends StatefulWidget {
//   final ProfileUser currentUser; // Pastikan ini tetap non-nullable

//   const EditProfilePage({super.key, required this.currentUser});

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final _formKey = GlobalKey<FormState>(); // Tambahkan FormKey untuk validasi

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController =
//       TextEditingController(); // Ini tetap ada tapi readOnly

//   bool _isLoading = false;
//   final ProfileService _profileService = ProfileService();
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

//   @override
//   void initState() {
//     super.initState();
//     _nameController.text = widget.currentUser.name;
//     _emailController.text =
//         widget.currentUser.email; // Email hanya ditampilkan, tidak diedit

//     // Tidak perlu memuat data dropdown atau inisialisasi _selected... jika hanya tampilan
//     // _fetchDropdownDataAndSetInitialValues();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   // Metode _fetchDropdownDataAndSetInitialValues() Dihapus jika tidak ada dropdown dinamis
//   // Future<void> _fetchDropdownDataAndSetInitialValues() async { ... }

//   Future<void> _onSaveChanges() async {
//     if (!_formKey.currentState!.validate()) {
//       // Validasi form
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Mohon lengkapi Nama Lengkap yang wajib diisi.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final String newName = _nameController.text.trim();
//     // Email tidak dikirimkan karena tidak diedit
//     // Jenis kelamin, trainingId, dan batchId akan diambil dari widget.currentUser ASLI
//     final String? originalJenisKelamin = widget.currentUser.jenisKelamin;
//     final int? originalTrainingId = widget.currentUser.trainingId;
//     final int? originalBatchId = widget.currentUser.batchId;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String? token =
//           await ApiService.getToken(); // Menggunakan ApiService.getToken()
//       if (token == null || token.isEmpty) {
//         throw Exception(
//           'Token otentikasi tidak ditemukan. Mohon login kembali.',
//         );
//       }

//       // Panggil service untuk memperbarui profil
//       // Penting: Kirimkan semua data yang dibutuhkan API, meskipun hanya nama yang diedit di UI ini.
//       // Data lain diambil dari currentUser asli.
//       final ProfileResponse response = await _profileService.updateProfileData(
//         token,
//         name: newName,
//         jenisKelamin: originalJenisKelamin, // Gunakan nilai asli
//         trainingId: originalTrainingId, // Gunakan nilai asli
//         batchId: originalBatchId, // Gunakan nilai asli
//       );

//       if (!mounted) return;

//       // Periksa apakah update berhasil
//       if (response.data != null) {
//         // Perbarui data di SharedPreferences
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString('user_name', response.data!.name);
//         await prefs.setString('user_email', response.data!.email);
//         await prefs.setString(
//           'user_jenis_kelamin',
//           response.data!.jenisKelamin ?? '',
//         );
//         if (response.data!.trainingId != null)
//           prefs.setInt('user_training_id', response.data!.trainingId!);
//         if (response.data!.batchId != null)
//           prefs.setInt('user_batch_id', response.data!.batchId!);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response.message),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // Kirim kembali objek ProfileUser yang diupdate ke halaman profil
//         Navigator.of(context).pop(response.data);
//       } else {
//         // Jika response.data null tapi message ada (misal: "data tidak berubah")
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response.message),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Save profile changes failed: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Gagal menyimpan perubahan: ${e.toString().replaceFirst('Exception: ', '')}',
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightBackground,
//       appBar: AppBar(
//         title: const Text('Edit Profil'),
//         backgroundColor: AppColors.historyBlueShape,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           // Wrap with Form for validation
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Informasi Pribadi',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textDark,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Nama Lengkap',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Nama tidak boleh kosong.';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               // Email (Read-only)
//               TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                   enabled: false, // Membuat tidak bisa diedit
//                   fillColor: Colors.grey[100], // Background abu-abu
//                   filled: true,
//                 ),
//                 readOnly: true, // Pastikan benar-benar read-only
//               ),
//               const SizedBox(height: 20),
//               // Jenis Kelamin (Tampilan Read-only)
//               _buildReadOnlyTextField(
//                 context,
//                 Icons.wc,
//                 'Jenis Kelamin',
//                 widget.currentUser.jenisKelamin == 'L'
//                     ? 'Laki-laki'
//                     : (widget.currentUser.jenisKelamin == 'P'
//                         ? 'Perempuan'
//                         : 'Tidak Tersedia'),
//               ),
//               const SizedBox(height: 20),
//               // Jurusan/Training (Tampilan Read-only)
//               _buildReadOnlyTextField(
//                 context,
//                 Icons.school,
//                 'Jurusan/Training',
//                 widget.currentUser.trainingTitle ??
//                     'Tidak Tersedia', // Menggunakan getter trainingTitle
//               ),
//               const SizedBox(height: 20),
//               // Batch (Tampilan Read-only)
//               _buildReadOnlyTextField(
//                 context,
//                 Icons.group,
//                 'Batch',
//                 widget.currentUser.batchKe ??
//                     'Tidak Tersedia', // Menggunakan getter batchKe
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _onSaveChanges,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.loginButtonColor,
//                     foregroundColor: AppColors.textLight,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child:
//                       _isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text(
//                             'Simpan Perubahan',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget helper baru untuk menampilkan field read-only
//   Widget _buildReadOnlyTextField(
//     BuildContext context,
//     IconData icon,
//     String label,
//     String value,
//   ) {
//     return TextFormField(
//       initialValue: value,
//       readOnly: true,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//         prefixIcon: Icon(icon),
//         enabled: false, // Membuat tidak bisa diedit (tampilan disabled)
//         fillColor: Colors.grey[100], // Background abu-abu
//         filled: true,
//       ),
//     );
//   }
// }

// // Extension untuk List agar punya firstWhereOrNull (tetap diperlukan jika masih digunakan di ProfilePage atau lainnya)
// extension ListExtension<T> on List<T> {
//   T? firstWhereOrNull(bool Function(T element) test) {
//     for (var element in this) {
//       if (test(element)) {
//         return element;
//       }
//     }
//     return null;
//   }
// }

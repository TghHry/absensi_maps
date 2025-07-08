import 'package:absensi_maps/utils/app_colors.dart' show AppColors;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps
// import 'package:provider/provider.dart'; // Untuk ThemeProvider


class KehadiranPage extends StatefulWidget {
  const KehadiranPage({super.key});

  @override
  State<KehadiranPage> createState() => _KehadiranPageState();
}

class _KehadiranPageState extends State<KehadiranPage> {
  GoogleMapController? mapController;

  // Lokasi default statis untuk peta
  static const LatLng _initialCameraPosition = LatLng(-6.2088, 106.8456); // Contoh: Jakarta
  final Set<Marker> _markers = {}; // Untuk menempatkan marker di peta

  final TextEditingController _noteController = TextEditingController(); // Controller untuk Note
  String _statusCheckIn = 'Belum Check in'; // Status lokal untuk card

  @override
  void initState() {
    super.initState();
    // Tambahkan marker default di lokasi awal
    _markers.add(
      const Marker(
        markerId: MarkerId('defaultLocation'),
        position: _initialCameraPosition,
        infoWindow: InfoWindow(title: 'Lokasi Kantor Pusat (Statis)'),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Fungsi placeholder untuk tombol Check in
  void _onCheckInButtonPressed() {
    setState(() {
      _statusCheckIn = 'Mencatat Check in...'; // Update status di UI
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Check in ditekan! Note: ${_noteController.text} (UI Simulasi)'),
        duration: const Duration(seconds: 2),
      ),
    );
    // Setelah simulasi, Anda bisa update status lagi
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _statusCheckIn = 'Check in Berhasil!';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // Background halaman Map
      body: Stack(
        children: [
          // Peta Statis
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _initialCameraPosition,
              zoom: 15.0,
            ),
            markers: _markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

          // Card "Check in" yang muncul di atas peta
          Positioned(
            bottom: 0, // Posisikan di bagian bawah layar
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.6, // Tinggi card relatif terhadap layar
              decoration: BoxDecoration(
                color: AppColors.loginCardColor, // Warna putih untuk card
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), // Sudut melengkung di kiri atas
                  topRight: Radius.circular(30), // Sudut melengkung di kanan atas
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5), // Bayangan ke atas
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Judul tengah
                  children: [
                    Text(
                      'Check in',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                    ),
                    const SizedBox(height: 25), // Jarak ke detail lokasi
                    // Your Location Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.black, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Location',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Jl. Citra Indah Utama No.18\nRT.04/RW.019, Desa Sukamaju,\nKecamatan Jonggol, Kabupaten Bogor,\nJawa Barat 16830', // Alamat statis
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[700],
                                      height: 1.5, // Line height
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25), // Jarak ke Note
                    // Note (Optional) Section
                    const Divider(height: 1, thickness: 1, color: Colors.grey), // Garis pemisah
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.notes, color: Colors.black, size: 24), // Icon Note
                        const SizedBox(width: 10),
                        Text(
                          'Note (Optional)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan jika perlu...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200], // Background TextField
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 25),
                    // Status Check in
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Status : $_statusCheckIn', // Menampilkan status
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _statusCheckIn.contains('Berhasil') ? Colors.green : AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const Spacer(), // Mendorong tombol ke bawah
                    // Tombol Check in
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onCheckInButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.loginButtonColor, // Warna biru tombol
                          foregroundColor: AppColors.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Sudut tombol
                          ),
                        ),
                        child: const Text(
                          'Check in',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tambahkan BottomNavigationBar di sini jika Anda tidak mengaturnya di MainScreen
          // Jika BottomNav di MainScreen, maka kode di bawah ini dihapus
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     color: AppColors.bottomNavBackground, // Warna kuning solid
          //     padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          //     child: BottomNavigationBar(
          //       // ... (item BottomNav)
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
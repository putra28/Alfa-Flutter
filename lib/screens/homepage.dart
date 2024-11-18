// lib/screens/homepage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedMenuItemId = 0;

  void _onMenuItemSelected(int itemId) {
    setState(() {
      selectedMenuItemId = itemId;
    });
    Navigator.pop(context); // Tutup drawer setelah memilih item
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0, // Agar image berada di pojok kiri
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Atur posisi elemen
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Image.asset(
                'assets/images/logo_alfamart_white.png',
                width: 75, // Sesuaikan ukuran logo
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Text(
                "Layanan Informasi Pembayaran PLN",
                style: GoogleFonts.dongle(
                  textStyle: const TextStyle(
                    fontSize: 28, // Sesuaikan ukuran teks
                    fontWeight: FontWeight
                        .bold, // Tambahkan jika ingin teks lebih tegas
                    color: Colors.white, // Pastikan warna sesuai tema AppBar
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          "This is Home Page! Selected Item: ${selectedMenuItemId + 1}",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

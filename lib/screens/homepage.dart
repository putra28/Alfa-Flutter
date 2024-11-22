// lib/screens/homepage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      titleSpacing: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Image.asset(
              'assets/images/logo_alfamart_white.png',
              width: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Text(
              "Layanan Informasi Tagihan PLN",
              style: GoogleFonts.dongle(
                textStyle: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              'assets/images/widthBanner.png',
              width: double.infinity,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Silahkan Pilih Produk',
            style: GoogleFonts.dongle(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/plnpostpaid');
                },
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3),
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        'assets/images/postpaid.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'PLN Postpaid',
                        style: GoogleFonts.dongle(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/plnprepaid');
                },
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3),
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        'assets/images/prepaid.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Text(
                        'PLN Prepaid',
                        style: GoogleFonts.dongle(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/plnnontaglis');
                },
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3),
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        'assets/images/nontaglis.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        'PLN Nontaglis',
                        style: GoogleFonts.dongle(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keterangan Produk :',
                    style: GoogleFonts.dongle(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '1. Pilih Produk PLN POSTPAID (Bayar Tagihan Listrik)',
                    style: GoogleFonts.dongle(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '2. Pilih Produk PLN PREPAID (Pembelian Token/Stroom Listrik)',
                    style: GoogleFonts.dongle(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '3. Pilih Produk PLN NONTAGLIS (Pembayaran Registrasi Pasang Baru atau Tambah Daya)',
                    style: GoogleFonts.dongle(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Layanan Informasi :',
                  style: GoogleFonts.dongle(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '- Gangguan dan Informasi PLN Hubungi Call Center PLN 123',
                  style: GoogleFonts.dongle(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  '- Bantuan Informasi Cek Tagihan SIlahkan Hubungi Kasir',
                  style: GoogleFonts.dongle(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  '- Sahabat Alfamart 1500959',
                  style: GoogleFonts.dongle(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

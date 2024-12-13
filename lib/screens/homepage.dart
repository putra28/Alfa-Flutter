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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: width * 0.04),
              child: Image.asset(
                'assets/images/logo_alfamart_white.png',
                width: width * 0.2,
                height: height * 0.2,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: width * 0.04),
              child: Text(
                "Layanan Informasi Tagihan PLN",
                style: GoogleFonts.dongle(
                  textStyle: TextStyle(
                    fontSize: width * 0.05,
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
            SizedBox(height: height * 0.02),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                'assets/images/widthBanner.png',
                width: width,
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'Silahkan Pilih Produk',
              style: GoogleFonts.dongle(
                textStyle: TextStyle(
                  fontSize: width * 0.05,
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
                        width: width * 0.25,
                        height: width * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3),
                          color: Colors.white,
                        ),
                        child: Image.asset(
                          'assets/images/postpaid.png',
                          width: width * 0.25,
                          height: width * 0.25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'PLN Postpaid',
                          style: GoogleFonts.dongle(
                            textStyle: TextStyle(
                              fontSize: width * 0.04,
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
                        width: width * 0.25,
                        height: width * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3),
                          color: Colors.white,
                        ),
                        child: Image.asset(
                          'assets/images/prepaid.png',
                          width: width * 0.25,
                          height: width * 0.25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text(
                          'PLN Prepaid',
                          style: GoogleFonts.dongle(
                            textStyle: TextStyle(
                              fontSize: width * 0.04,
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
                        width: width * 0.25,
                        height: width * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3),
                          color: Colors.white,
                        ),
                        child: Image.asset(
                          'assets/images/nontaglis.png',
                          width: width * 0.25,
                          height: width * 0.25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          'PLN Nontaglis',
                          style: GoogleFonts.dongle(
                            textStyle: TextStyle(
                              fontSize: width * 0.04,
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
            SizedBox(height: height * 0.02),
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
                        textStyle: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '1. Pilih Produk PLN POSTPAID (Bayar Tagihan Listrik)',
                      style: GoogleFonts.dongle(
                        textStyle: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      '2. Pilih Produk PLN PREPAID (Pembelian Token/Stroom Listrik)',
                      style: GoogleFonts.dongle(
                        textStyle: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      '3. Pilih Produk PLN NONTAGLIS (Pembayaran Registrasi Pasang Baru atau Tambah Daya)',
                      style: GoogleFonts.dongle(
                        textStyle: TextStyle(
                          fontSize: width * 0.035,
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
                      textStyle: TextStyle(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '- Gangguan dan Informasi PLN Hubungi Call Center PLN 123',
                    style: GoogleFonts.dongle(
                      textStyle: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '- Bantuan Informasi Cek Tagihan SIlahkan Hubungi Kasir',
                    style: GoogleFonts.dongle(
                      textStyle: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '- Sahabat Alfamart 1500959',
                    style: GoogleFonts.dongle(
                      textStyle: TextStyle(
                        fontSize: width * 0.035,
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
      ),
    );
  }
}
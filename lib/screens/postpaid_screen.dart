// lib/screens/postpaid_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ISOMessageCreate.dart'; // Import file processor.dart
import '../services/ISOMessageParsing.dart'; // Import file untuk ISOMessageParsing

class postpaid_screen extends StatefulWidget {
  const postpaid_screen({super.key});

  @override
  _postpaid_screenState createState() => _postpaid_screenState();
}

class _postpaid_screenState extends State<postpaid_screen> {
  final TextEditingController _controller = TextEditingController();
  String _outputISOMessage = ""; // Variabel untuk menyimpan output
  String _outputISOMessageParsing = ""; // Variabel untuk menyimpan output

  void _handleSubmit() async {
    final processor = Isomessagecreate(); // Buat instance Processor
    final processorParsing = ISOMessageParsing(); // Buat instance Processor
    final isoMessage =
        processor.createIsoMessage(_controller.text); // Proses input
    final parsingISO =
        processorParsing.printResponse(_controller.text); // Proses input

    setState(() {
      _outputISOMessage = isoMessage; // Simpan ISO message yang dikirim
      _outputISOMessageParsing =
          parsingISO; // Status awal untuk parsing
    });

    // Kirim ISO message ke server dan tunggu respons
    // // String serverResponse = await processor.sendISOMessage(isoMessage);

    // setState(() {
    //   _outputISOMessageParsing = serverResponse; // Simpan respons dari server
    // });
  }

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
                'Masukkan ID Pelanggan',
                style: GoogleFonts.dongle(
                  textStyle: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'ID Pelanggan',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _handleSubmit, // Panggil fungsi handleSubmit
                        child: Text('Submit'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_outputISOMessageParsing.isEmpty)
                Column(
                  children: [
                    Image.asset('assets/images/albi.png', width: 100, height: 100),
                    Text(
                      'Silahkan Masukkan ID Pelanggan Dengan Benar',
                      style: GoogleFonts.dongle(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 10),
              Text(
                'Output Response:' + _outputISOMessageParsing, // Tampilkan hasil output
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ));
  }
}
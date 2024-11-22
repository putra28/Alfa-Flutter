// lib/screens/nontaglis_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ISOMessageCreate.dart'; // Import file processor.dart

class nontaglis_screen extends StatefulWidget {
  const nontaglis_screen({super.key});

  @override
  _nontaglis_screenState createState() => _nontaglis_screenState();
}

class _nontaglis_screenState extends State<nontaglis_screen> {
  final TextEditingController _controller = TextEditingController();
  String _outputISOMessage = ""; // Variabel untuk menyimpan output
  String _outputISOMessageParsing = ""; // Variabel untuk menyimpan output

  void _handleSubmit() async {
    final processor = Isomessagecreate(); // Buat instance Processor
    final isoMessage =
        processor.createIsoMessage(_controller.text); // Proses input

    setState(() {
      _outputISOMessage = isoMessage; // Simpan ISO message yang dikirim
      _outputISOMessageParsing =
          'Waiting for response...'; // Status awal untuk parsing
    });

    // Kirim ISO message ke server dan tunggu respons
    String serverResponse = await processor.sendISOMessage(isoMessage);

    setState(() {
      _outputISOMessageParsing = serverResponse; // Simpan respons dari server
    });
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
              Image.asset('assets/images/banner.jpg'),
              SizedBox(height: 20),
              Text(
                'Masukkan No. Registrasi',
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
                          labelText: 'No. Registrasi',
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
              Image.asset('assets/images/albi.png', width: 100, height: 100),
              Text(
                'Silahkan Masukkan No. Registrasi Dengan Benar',
                style: GoogleFonts.dongle(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Output ISO Message:' +
                    _outputISOMessage, // Tampilkan hasil output
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Output Response:' +
                    _outputISOMessageParsing, // Tampilkan hasil output
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ));
  }
}

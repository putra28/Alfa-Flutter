// lib/screens/Login.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';
import 'homepage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _controller = TextEditingController();
  void _handleSubmit() async {
    print("ID Toko: ${_controller.text}");
    if (_controller.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'ID Toko Perlu Diisi',
        confirmBtnText: 'OK',
        confirmBtnColor: Theme.of(context).colorScheme.primary,
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

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
              'Silahkan Masukkan ID Toko',
              style: GoogleFonts.dongle(
                textStyle: TextStyle(
                  fontSize: width * 0.05,
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
                    margin: EdgeInsets.only(left: width * 0.05),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ID Toko',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(right: width * 0.05),
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text('Cek'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            Column(
              children: [
                Image.asset('assets/images/albi.png',
                    width: width * 0.20, height: width * 0.20),
                Text(
                  'Silahkan Masukkan ID Toko Dengan Benar',
                  style: GoogleFonts.dongle(
                    textStyle: TextStyle(
                      fontSize: width * 0.05,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

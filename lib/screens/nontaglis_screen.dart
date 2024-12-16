// lib/screens/nontaglis_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ISOMessageCreate.dart';
import '../services/postpaid_ISOMessageParsing.dart';
import 'package:quickalert/quickalert.dart';

class nontaglis_screen extends StatefulWidget {
  const nontaglis_screen({super.key});

  @override
  _nontaglis_screenState createState() => _nontaglis_screenState();
}

class _nontaglis_screenState extends State<nontaglis_screen> {
  final TextEditingController _controller = TextEditingController();
  String _outputISOMessage = "";
  String _outputISOMessageParsing = "";

  void _handleSubmit() async {
    if (_controller.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'No. Registrasi Perlu Diisi',
        confirmBtnText: 'OK',
        confirmBtnColor: Theme.of(context).colorScheme.primary,
      );
      return;
    } 
    else {
      final processor = Isomessagecreate();
      final processorParsing = ISOMessageParsing();
      final isoMessage = processor.createIsoMessage(_controller.text);
      final isoMessagetoSent = 'xx' + isoMessage;

      // try {
      //   String serverResponse =
      //       await processor.sendISOMessage(isoMessagetoSent);
      //   print('Server Response: $serverResponse');
      //   if (!serverResponse.startsWith("Terjadi Kesalahan")) {
      //     final parsingISO =
      //         processorParsing.printResponse(serverResponse, _controller.text);
      //     setState(() {
      //       _outputISOMessageParsing = parsingISO;
      //     });
      //   } else {
      //     String serverResponseClean =
      //         serverResponse.replaceFirst("Terjadi Kesalahan: ", "");
      //     QuickAlert.show(
      //       context: context,
      //       type: QuickAlertType.error,
      //       title: 'Terjadi Kesalahan',
      //       text: serverResponseClean,
      //       confirmBtnText: 'OK',
      //       confirmBtnColor: Theme.of(context).colorScheme.primary,
      //     );
      //     _controller.clear();
      //   }
      // } catch (e) {
      //   print('Error: $e');
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
                  width: width * 0.20,
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
                margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Image.asset(
                  'assets/images/widthBanner.png',
                  width: double.infinity,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Masukkan No. Registrasi',
                style: GoogleFonts.dongle(
                  textStyle: TextStyle(
                    fontSize: width * 0.07,
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
                          labelText: 'No. Registrasi',
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
              if (_outputISOMessageParsing.isEmpty)
                Column(
                  children: [
                    Image.asset('assets/images/albi.png',
                        width: width * 0.20, height: width * 0.20),
                    Text(
                      'Silahkan Masukkan ID Pelanggan Dengan Benar',
                      style: GoogleFonts.dongle(
                        textStyle: TextStyle(
                          fontSize: width * 0.05,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              if (!_outputISOMessageParsing.isEmpty)
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'PLN nontaglis \n',
                          style: GoogleFonts.dongle(
                            textStyle: TextStyle(
                              fontSize: width * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: '$_outputISOMessageParsing',
                          style: GoogleFonts.dongle(
                            textStyle: TextStyle(
                              fontSize: width * 0.05,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: height * 0.01),
              if (!_outputISOMessageParsing.isEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                        height: height * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              _outputISOMessageParsing = "";
                            });
                          },
                          child: Text('Clear Data'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                        height: height * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button press
                          },
                          child: Text('Booking No. Antrian'),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ));
  }
}

// lib/screens/postpaid_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ISOMessageCreate.dart';
import '../services/Postpaid_ISOMessageParsing.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/BookingAntrian.dart';
import '../services/InquiryServices.dart';
// import '../services/ISOMessageParser.dart';

class postpaid_screen extends StatefulWidget {
  const postpaid_screen({super.key});

  @override
  _postpaid_screenState createState() => _postpaid_screenState();
}

class _postpaid_screenState extends State<postpaid_screen> {
  final TextEditingController _controller = TextEditingController();
  String _outputISOMessage = "";
  String _outputISOMessageParsing = "";

  void _handleSubmit() async {
    if (_controller.text.length < 12) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'ID Pelanggan Tidak Valid',
        confirmBtnText: 'OK',
        confirmBtnColor: Theme.of(context).colorScheme.primary,
      );
      return;
    }
    if (_controller.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'ID Pelanggan Perlu Diisi',
        confirmBtnText: 'OK',
        confirmBtnColor: Theme.of(context).colorScheme.primary,
      );
      return;
    } else {
      final processor = Isomessagecreate();
      final processorInquiry = InquiryServices();
      final processorParsing = ISOMessageParsing();
      // final processorParsing = ISOMessageParser();
      String productCode = "14501";
      final isoMessage =
          processor.createIsoMessage(_controller.text, productCode);
      final isoMessagetoSent = 'XX' + isoMessage;

      final parsingISO = await processorParsing.printResponse(_controller.text);
      if (parsingISO.startsWith("Terjadi Kesalahan")) {
        String serverResponseClean =
            parsingISO.replaceFirst("Terjadi Kesalahan: ", "");
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: serverResponseClean,
          confirmBtnText: 'OK',
          confirmBtnColor: Theme.of(context).colorScheme.primary,
        );
        _controller.clear();
      } else {
        setState(() {
          _outputISOMessage = isoMessage;
          _outputISOMessageParsing = parsingISO.trim();
        });
      }

      // try {
      //   String serverResponse =
      //       await processorInquiry.sendISOMessage(isoMessagetoSent);
      //   if (!serverResponse.startsWith("Terjadi Kesalahan")) {
      //     final parsingISO = await processorParsing.printResponse(
      //         serverResponse, _controller.text);
      //     if (parsingISO.startsWith("Terjadi Kesalahan")) {
      //       String serverResponseClean =
      //           parsingISO.replaceFirst("Terjadi Kesalahan: ", "");
      //       QuickAlert.show(
      //         context: context,
      //         type: QuickAlertType.error,
      //         title: serverResponseClean,
      //         confirmBtnText: 'OK',
      //         confirmBtnColor: Theme.of(context).colorScheme.primary,
      //       );
      //       _controller.clear();
      //     } else {
      //       setState(() {
      //         _outputISOMessageParsing = parsingISO;
      //       });
      //     }
      //   } else {
      //     String serverResponseClean =
      //         serverResponse.replaceFirst("Terjadi Kesalahan: ", "");
      //     QuickAlert.show(
      //       context: context,
      //       type: QuickAlertType.error,
      //       title: serverResponseClean,
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
                      fontSize: width * 0.04,
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
                margin: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Image.asset(
                  'assets/images/widthBanner.png',
                  width: double.infinity,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Masukkan ID Pelanggan',
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
                      margin: EdgeInsets.only(left: width * 0.04),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'ID Pelanggan',
                          labelStyle: GoogleFonts.dongle(
                            textStyle: TextStyle(
                              fontSize: width * 0.04,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.only(right: width * 0.04),
                      height: height * 0.07,
                      child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _handleSubmit();
                        },
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
                          fontSize: width * 0.04,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              if (!_outputISOMessageParsing.isEmpty)
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: 'PLN Postpaid \n',
                              style: GoogleFonts.dongle(
                                textStyle: TextStyle(
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TextSpan(
                              text: '$_outputISOMessageParsing',
                              style: GoogleFonts.dongle(
                                textStyle: TextStyle(
                                  fontSize: width * 0.04,
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
              SizedBox(height: height * 0.01),
              if (!_outputISOMessageParsing.isEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: width * 0.04),
                        height: height * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              _outputISOMessageParsing = "";
                            });
                          },
                          child: Text(
                            'Clear Data',
                            style: GoogleFonts.dongle(
                              textStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: width * 0.04),
                        height: height * 0.07,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              // Logic untuk melanjutkan proses pembayaran
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? Method = "Insert Antrian Postpaid";
                              String? IDToko = prefs.getString('IDToko');
                              String? idPelanggan =
                                  prefs.getString('idPelanggan');
                              int? totalTagihan = prefs.getInt('totalTagihan');
                              int? totalAdmin = prefs.getInt('totalAdmin');
                              int? RPTagPLN = prefs.getInt('RPTagPLN');
                              int? totalBayar = prefs.getInt('totalBayar');
                              String? SCREF = prefs.getString('SCREF');

                              Map<String, dynamic> dataToSend = {
                                "var_kdtoko": IDToko,
                                "var_amount": totalBayar,
                                "var_idpel": idPelanggan,
                                "var_rptag": RPTagPLN,
                                "var_admttl": totalAdmin,
                                "var_lembar": totalTagihan,
                                "var_scref": SCREF
                              };
                              print(dataToSend);

                              await BookingAntrian.bookingAntrian(
                                  Method!, dataToSend!);

                              setState(() {
                                _controller.clear();
                                _outputISOMessageParsing = "";
                              });
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                title: 'Berhasil Booking No. Antrian',
                                text:
                                    "No. Antrian : ${prefs.getString('noantrian')}\n"
                                    + "ID Pelanggan : ${prefs.getString('idPelanggan')}",
                                confirmBtnText: 'OK',
                                confirmBtnColor: Colors.green,
                              );
                            } catch (e) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Terjadi Kesalahan',
                                text: "Gagal Melakukan Booking No. Antrian",
                                confirmBtnText: 'OK',
                                confirmBtnColor:
                                    Theme.of(context).colorScheme.primary,
                              );
                            }
                          },
                          child: Text(
                            'Booking No. Antrian',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dongle(
                              textStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: height * 0.01),
            ],
          ),
        ));
  }
}

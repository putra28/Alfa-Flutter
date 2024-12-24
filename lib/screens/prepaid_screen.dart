import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/Prepaid_ISOMessageCreate.dart'; // Import file processor.dart
import '../services/Prepaid_ISOMessageParsing.dart'; // Import file untuk ISOMessageParsing
import '../widgets/CustomRadioWidget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/BookingAntrian.dart';

class prepaid_screen extends StatefulWidget {
  const prepaid_screen({super.key});

  @override
  _PrepaidScreenState createState() => _PrepaidScreenState();
}

class _PrepaidScreenState extends State<prepaid_screen> {
  final TextEditingController _controller = TextEditingController();

  String _outputISOMessage = ""; // Variabel untuk menyimpan output
  String _outputISOMessageParsing = ""; // Variabel untuk menyimpan output
  String? _denomValue = "";
  String? _totBayarValue = "";
  int _selectedDenom = 0;
  int _adminBank = 2500;
  int _totalBayar = 0;
  final _formattedAdmin =
      NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0)
          .format(2500);

  void _onRadioValueChanged(int value) {
    _denomValue =
        NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0)
            .format(value);
    setState(() {
      _selectedDenom = value;
      _totalBayar = value + _adminBank;
    });
    _totBayarValue =
        NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0)
            .format(_totalBayar);
  }

  // Modify the _handleSubmit method to handle asynchronous operations properly
  void _handleSubmit() async {
    if (_controller.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'ID Pelanggan / No. Meter Perlu Diisi',
        confirmBtnText: 'OK',
        confirmBtnColor: Theme.of(context).colorScheme.primary,
      );
      return;
    } else {
      final processor = Isomessagecreate();
      final processorParsing = ISOMessageParsing();
      final isoMessage = processor.createIsoMessage(_controller.text);
      final isoMessagetoSent = 'XX' + isoMessage;

      final parsingISO = await processorParsing.printResponse(_controller.text);
      if (parsingISO.startsWith("Terjadi Kesalahan")) {
        String serverResponseClean =
            parsingISO.replaceFirst("Terjadi Kesalahan: ", "");
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Terjadi Kesalahan',
          text: serverResponseClean,
          confirmBtnText: 'OK',
          confirmBtnColor: Theme.of(context).colorScheme.primary,
        );
        _controller.clear();
      } else {
        SharedPreferences prefs =
            await SharedPreferences.getInstance();
        String? Method = "Get Denom Prepaid";
        String? IDToko = prefs.getString('IDToko');
        Map<String, dynamic> dataToSend = {
          "var_kdtoko": IDToko,
        };
        
        await BookingAntrian.GetDenom(
          Method!,
          dataToSend!
        );
        setState(() {
          _outputISOMessage = isoMessage;
          _outputISOMessageParsing = parsingISO.trim();
        });
      }

      // try {
      //   String serverResponse = await processor
      //       .sendISOMessage(isoMessagetoSent); // Asynchronous call
      //   if (!serverResponse.startsWith("Terjadi Kesalahan")) {
      //     final parsingISO = await processorParsing.printResponse(
      //         serverResponse, _controller.text); // Await response here
      //     if (parsingISO.startsWith("Terjadi Kesalahan")) {
      //       String serverResponseClean =
      //           parsingISO.replaceFirst("Terjadi Kesalahan: ", "");
      //       QuickAlert.show(
      //         context: context,
      //         type: QuickAlertType.error,
      //         title: 'Terjadi Kesalahan',
      //         text: serverResponseClean,
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
              'Masukkan No. Meter / ID Pelanggan',
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
                        labelText: 'No. Meter / ID Pelanggan',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(right: width * 0.05),
                    height: height * 0.07,
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
                    'Silahkan Masukkan No. Meter / ID Pelanggan Dengan Benar',
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
                margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'PLN Prepaid \n',
                            style: GoogleFonts.dongle(
                              textStyle: TextStyle(
                                fontSize: width * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: '$_outputISOMessageParsing\n',
                            style: GoogleFonts.dongle(
                              textStyle: TextStyle(
                                fontSize: width * 0.05,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (_outputISOMessageParsing.startsWith('NAMA'))
                            TextSpan(
                              text: 'PILIH DENOM : $_denomValue',
                              style: GoogleFonts.dongle(
                                textStyle: TextStyle(
                                  fontSize: width * 0.05,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_outputISOMessageParsing.startsWith('NAMA'))
                      CustomRadioWidget(
                        valueChanged: _onRadioValueChanged,
                        initialValue: _selectedDenom,
                      ),
                    if (_outputISOMessageParsing.startsWith('NAMA'))
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  'ADMIN BANK : $_formattedAdmin\nTOTAL BAYAR : $_totBayarValue',
                              style: GoogleFonts.dongle(
                                textStyle: TextStyle(
                                  fontSize: width * 0.05,
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
                      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      height: height * 0.07,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _outputISOMessageParsing = "";
                            _selectedDenom = 0;
                            _denomValue = "";
                            _totalBayar = 0;
                            _totBayarValue = "";
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
                        onPressed: () async {
                          try {
                            // Logic untuk melanjutkan proses pembayaran
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? Method = "Insert Antrian Prepaid";
                            String? IDToko = prefs.getString('IDToko');
                            String? idpel = prefs.getString('idpel');
                            int? adminTotal = 2500;

                            Map<String, dynamic> dataToSend = {
                              "var_kdtoko": IDToko,
                              "var_denom": _selectedDenom,
                              "var_idpel": idpel,
                              "var_admttl": adminTotal,
                            };

                            await BookingAntrian.bookingAntrian(
                              Method!,
                              dataToSend!
                            );

                            setState(() {
                              _controller.clear();
                              _outputISOMessageParsing = "";
                              _selectedDenom = 0;
                              _denomValue = "";
                              _totalBayar = 0;
                              _totBayarValue = "";
                            });
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              title: 'Berhasil Melakukan Booking No. Antrian',
                              text: "No. Antrian : ${prefs.getString('noantrian')}",
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
                        child: Text('Booking No. Antrian'),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: height * 0.01),
          ],
        ),
      ),
    );
  }
}

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../services/ISOMessageCreate.dart';
import '../services/Prepaid_ISOMessageParsing.dart';
import '../widgets/CustomRadioWidget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/BookingAntrian.dart';
import '../services/InquiryServices.dart';

class prepaid_screen extends StatefulWidget {
  const prepaid_screen({super.key});

  @override
  _PrepaidScreenState createState() => _PrepaidScreenState();
}

class _PrepaidScreenState extends State<prepaid_screen> {
  final TextEditingController _controller = TextEditingController();
  final currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  String _outputISOMessageParsing = "";
  String? _denomValue = "";
  String? _totBayarValue = "";
  int _selectedDenom = 0;
  int _adminBank = 2500;
  int _totalBayar = 0;
  bool _isLoading = false;

  String get _formattedAdmin => currencyFormatter.format(_adminBank);

  Widget _buildShimmerEffect() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PLN Prepaid',
              style: GoogleFonts.dongle(
                textStyle: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            _buildShimmerRow("ID Pelanggan"),
            _buildShimmerRow("Nama"),
            _buildShimmerRow("Tarif/Daya"),
            _buildShimmerRow("No Meter"),
            _buildShimmerRow("Daya"),
            _buildShimmerRow("Status"),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 20,
            color: Colors.white,
          ),
          Text(" : "),
          Expanded(
            child: Container(
              height: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _onRadioValueChanged(int value) {
    setState(() {
      _selectedDenom = value;
      _denomValue = currencyFormatter.format(value);
      _totalBayar = value + _adminBank;
      _totBayarValue = currencyFormatter.format(_totalBayar);
    });
  }

  void _showError(String title, String message) {
    String exceptionClean = message
        .replaceFirst("Terjadi Kesalahan: ", "")
        .replaceFirst("Exception: ", "");
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: exceptionClean,
      confirmBtnText: 'OK',
      confirmBtnColor: Theme.of(context).colorScheme.primary,
    );
  }

  Future<void> _validateInput() async {
    if (_controller.text.isEmpty) {
      throw Exception('ID Pelanggan / No. Meter Perlu Diisi');
    }
    if (_controller.text.length < 11) {
      throw Exception('No. Meter / ID Pelanggan Tidak Valid');
    }
  }

  Future<void> _handleSubmit() async {
    try {
      await _validateInput();

      setState(() {
        _isLoading = true;
        _outputISOMessageParsing = "";
      });

      final processor = Isomessagecreate();
      final processorInquiry = InquiryServices();
      final processorParsing = ISOMessageParsing();
      String productCode = "53502";
      final isoMessagetoSent =
          "XX" + processor.createIsoMessage(_controller.text, productCode);

      await Future.delayed(Duration(seconds: 3));

      final parsingISO = await processorParsing.printResponse(_controller.text);

      if (parsingISO.startsWith("Terjadi Kesalahan")) {
        throw Exception(parsingISO.replaceFirst("Terjadi Kesalahan: ", ""));
      }

      // Get denom data
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String Method = "Get Denom Prepaid";
          String? IDToko = prefs.getString('IDToko');

          await BookingAntrian.GetDenom(Method, {"var_kdtoko": IDToko});

          setState(() {
            _isLoading = false;
            _outputISOMessageParsing = parsingISO.trim();
          });

      // String serverResponse = await processorInquiry.sendISOMessage(isoMessagetoSent); // Asynchronous call
      // if (!serverResponse.startsWith("Terjadi Kesalahan")) {
      //   final parsingISO = await processorParsing.printResponse(
      //       serverResponse, _controller.text);
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   if (parsingISO.startsWith("Terjadi Kesalahan")) {
      //     String serverResponseClean =
      //         parsingISO.replaceFirst("Terjadi Kesalahan: ", "");
      //     QuickAlert.show(
      //       context: context,
      //       type: QuickAlertType.error,
      //       title: serverResponseClean,
      //       confirmBtnText: 'OK',
      //       confirmBtnColor: Theme.of(context).colorScheme.primary,
      //     );
      //     _controller.clear();
      //   } else {
      //     setState(() {
      //       _outputISOMessageParsing = parsingISO;
      //     });
          
      //     // Get denom data
      //     SharedPreferences prefs = await SharedPreferences.getInstance();
      //     String Method = "Get Denom Prepaid";
      //     String? IDToko = prefs.getString('IDToko');

      //     await BookingAntrian.GetDenom(Method, {"var_kdtoko": IDToko});

      //     setState(() {
      //       _isLoading = false;
      //       _outputISOMessageParsing = parsingISO.trim();
      //     });
      //   }
      // } else {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   String serverResponseClean = serverResponse.replaceFirst("Terjadi Kesalahan: ", "");
      //   _controller.clear();
      //   QuickAlert.show(
      //     context: context,
      //     type: QuickAlertType.error,
      //     title: serverResponseClean,
      //     confirmBtnText: 'OK',
      //     confirmBtnColor: Theme.of(context).colorScheme.primary,
      //   );
      // }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showError('Terjadi Kesalahan', e.toString());
      _controller.clear();
    }
  }

  Future<void> _handleBooking() async {
    try {
      if (_selectedDenom == 0) {
        throw Exception('Denom Tidak Boleh Kosong');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String Method = "Insert Antrian Prepaid";
      Map<String, dynamic> dataToSend = {
        "var_kdtoko": prefs.getString('IDToko'),
        "var_denom": _selectedDenom,
        "var_idpel": prefs.getString('idpel'),
        "var_admttl": 3500,
        "var_scref": prefs.getString('SCREF'),
      };

      await BookingAntrian.bookingAntrian(Method, dataToSend);

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Berhasil Booking Antrian',
        text: "No. Antrian : ${prefs.getString('noantrian')}\n"
            "ID Pelanggan : ${prefs.getString('idpel')}\n"
            "Denom : ${currencyFormatter.format(_selectedDenom)}",
        confirmBtnText: 'OK',
        confirmBtnColor: Colors.green,
      );
      setState(() {
        _controller.clear();
        _outputISOMessageParsing = "";
        _selectedDenom = 0;
        _denomValue = "";
        _totalBayar = 0;
        _totBayarValue = "";
      });
    } catch (e) {
      _showError('Terjadi Kesalahan', 'Gagal Melakukan Booking Antrian');
    }
  }

  void _handleClear() {
    setState(() {
      _controller.clear();
      _outputISOMessageParsing = "";
      _selectedDenom = 0;
      _denomValue = "";
      _totalBayar = 0;
      _totBayarValue = "";
    });
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
              'Masukkan No. Meter / ID Pelanggan',
              style: GoogleFonts.dongle(
                textStyle: TextStyle(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            _buildInputSection(width, height),
            SizedBox(height: height * 0.02),
            if (_isLoading)
              _buildShimmerEffect()
            else if (_outputISOMessageParsing.isEmpty)
              _buildEmptyState(width)
            else
              _buildResultSection(width),
            SizedBox(height: height * 0.01),
            if (!_outputISOMessageParsing.isEmpty)
              _buildActionButtons(width, height),
            SizedBox(height: height * 0.01),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(double width, double height) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Container(
            margin: EdgeInsets.only(left: width * 0.04),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'No. Meter / ID Pelanggan',
                labelStyle: GoogleFonts.dongle(
                  textStyle: TextStyle(fontSize: width * 0.04),
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
              child: Text(
                'Cek',
                style: GoogleFonts.dongle(
                  textStyle: TextStyle(
                    fontSize: width * 0.04,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(double width) {
    return Column(
      children: [
        Image.asset(
          'assets/images/albi.png',
          width: width * 0.20,
          height: width * 0.20,
        ),
        Text(
          'Silahkan Masukkan No. Meter / ID Pelanggan Dengan Benar',
          style: GoogleFonts.dongle(
            textStyle: TextStyle(
              fontSize: width * 0.04,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(double width) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'PLN Prepaid \n',
                  style: GoogleFonts.dongle(
                    textStyle: TextStyle(
                      fontSize: width * 0.05,
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
          if (_outputISOMessageParsing.startsWith('NAMA')) ...[
            CustomRadioWidget(
              valueChanged: _onRadioValueChanged,
              initialValue: _selectedDenom,
            ),
            RichText(
              text: TextSpan(
                text:
                    'ADMIN BANK  : $_formattedAdmin\nTOTAL BAYAR : $_totBayarValue',
                style: GoogleFonts.dongle(
                  textStyle: TextStyle(
                    fontSize: width * 0.05,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(double width, double height) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.04),
            height: height * 0.07,
            child: ElevatedButton(
              onPressed: _handleClear,
              child: Text(
                'Clear Data',
                style: GoogleFonts.dongle(
                  textStyle: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.white,
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
              onPressed: () {
                FocusScope.of(context).unfocus();
                _handleBooking();
              },
              child: Text(
                'Booking No. Antrian',
                textAlign: TextAlign.center,
                style: GoogleFonts.dongle(
                  textStyle: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

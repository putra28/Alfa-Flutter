import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingAntrian {
  static final String _url = 'http://168.168.10.12:2882/api/link-alfa';

  static Future<void> bookingAntrian(
      String method, String kdtoko, String amount, String idpel, String rptag, String admttl, String lembar) async {
    final data = {
      "method": method,
      "data": {
        "var_kdtoko": kdtoko,
        "var_amount": amount,
        "var_idpel": idpel,
        "var_rptag": rptag,
        "var_admttl": admttl,
        "var_lembar": lembar
      }
    };

    final response = await http.post(Uri.parse(_url),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));

    if (response.statusCode == 200) {
      print('Berhasil mengirim data');
    } else {
      print('Gagal mengirim data');
      throw Exception('Gagal mengirim data: ${response.statusCode}');
    }
  }
}

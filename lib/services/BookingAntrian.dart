import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingAntrian {
  static final String _url = 'http://168.168.10.12:2882/api/link-alfa';

  static Future<void> bookingAntrian(
      String? method,
      Map<String, dynamic> datatoSend
      ) async {
    final data = {
      "method": method,
      "data": datatoSend
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

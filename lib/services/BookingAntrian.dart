import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<void> GetDenom(
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
      print('Berhasil mendapatkan data');
      final responseData = jsonDecode(response.body);

      // Cek apakah respons memiliki array `data`
      if (responseData['data'] != null) {
        List<dynamic> denomData = responseData['data'];
        // Hapus elemen pertama
        denomData.removeAt(0);

        // Simpan ke session menggunakan SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('denomData', jsonEncode(denomData));
        String? denomm = prefs.getString('denomData');

        // print("Denom : $denomm");
        print("Data denom berhasil disimpan ke session");
      } else {
        print("Respons tidak mengandung data");
      }
    } else {
      print('Gagal mendapatkan data');
      throw Exception('Gagal mendapatkan data: ${response.statusCode}');
    }
  }
}

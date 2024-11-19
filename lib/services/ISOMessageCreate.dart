import 'Postpaid_bitmap.dart';
import 'dart:io';

class Isomessagecreate {
  // Fungsi untuk membangun ISO message
  String createIsoMessage(String inputValue) {
    // Menggunakan bitmap dari PostpaidBitmap
    String isoBitmap = PostpaidBitmap.buildIsoBitmap();

    // Elemen-elemen ISO message
    String mti = "0200";
    String bit2 = "14501";
    String bit3 = "380000";
    String bit7 = _currentTimestamp("MMddHHmmss");
    String bit11 = "007434";
    String bit12 = _currentTimestamp("HHmmss");
    String bit13 = _currentTimestamp("MMdd");
    String bit15 = _futureDateTimestamp("MMdd", daysAhead: 1);
    String bit18 = "6021";
    String bit32 = "ALN32SATPZ01P333";
    String bit37 = "000000000001";
    String bit41 = "54ALF001";
    String bit42 = "201000145100000012";
    String bit48 = inputValue; // Input pelanggan
    String bit49 = "360";
    String endMessage = "\u0003";

    // Panjang dinamis untuk bit2 dan bit32
    String lengthBit2 = bit2.length.toString().padLeft(2, '0');
    String lengthBit32 = bit32.length.toString().padLeft(2, '0');

    // Bangun ISO message
    String isoMessage = mti +
        isoBitmap +
        lengthBit2 +
        bit2 +
        bit3 +
        bit7 +
        bit11 +
        bit12 +
        bit13 +
        bit15 +
        bit18 +
        lengthBit32 +
        bit32 +
        bit37 +
        bit41 +
        bit42 +
        bit48 +
        bit49 +
        endMessage;

    return isoMessage;
  }

  // Fungsi untuk mendapatkan waktu saat ini dalam format tertentu
  String _currentTimestamp(String format) {
    DateTime now = DateTime.now();
    return _formatDateTime(now, format);
  }

  // Fungsi untuk mendapatkan waktu di masa depan dalam format tertentu
  String _futureDateTimestamp(String format, {int daysAhead = 0}) {
    DateTime futureDate = DateTime.now().add(Duration(days: daysAhead));
    return _formatDateTime(futureDate, format);
  }

  // Fungsi untuk memformat waktu sesuai pola
  String _formatDateTime(DateTime date, String format) {
    String formatted = format
        .replaceAll("MMdd",
            "${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}")
        .replaceAll("HHmmss",
            "${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}${date.second.toString().padLeft(2, '0')}");
    return formatted;
  }

  Future<String> sendISOMessage(String isoMessage) async {
    try {
      // Coba koneksi ke server
      final socket = await Socket.connect('168.168.10.175', 7100)
          .timeout(Duration(seconds: 5), onTimeout: () {
        throw Exception('Connection timed out');
      });
      print('Connected to the server.');

      try {
        // Kirim ISO message
        socket.write(isoMessage);
        await socket.flush();
        print('ISO message sent.');

        // Buffer untuk menyimpan respons
        final responseBuffer = StringBuffer();

        // Mendengarkan respons dari server
        await socket.listen(
          (data) {
            // Tambahkan data yang diterima ke buffer
            responseBuffer.write(String.fromCharCodes(data));
          },
          onDone: () {
            print('Response received.');
          },
          onError: (error) {
            throw Exception('Error occurred while receiving response: $error');
          },
        ).asFuture();

        // Tutup koneksi setelah selesai
        await socket.close();

        // Jika respons kosong, anggap sebagai kegagalan menerima data
        if (responseBuffer.isEmpty) {
          throw Exception('No response received from server');
        }

        // Mengembalikan respons
        return responseBuffer.toString();
      } catch (e) {
        print('Failed to receive response: $e');
        return 'Error: Failed to receive response. $e';
      }
    } catch (e) {
      print('Failed to connect to the server: $e');
      return 'Error: Failed to connect to the server. $e';
    }
  }
}

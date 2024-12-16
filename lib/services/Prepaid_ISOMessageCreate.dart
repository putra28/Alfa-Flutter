import 'Postpaid_bitmap.dart';
import 'dart:io';

class Isomessagecreate {
  // Fungsi untuk membangun ISO message
  String createIsoMessage(String inputValue) {
    // Menggunakan bitmap dari PostpaidBitmap
    String isoBitmap = PostpaidBitmap.buildIsoBitmap();

    // Hitung panjang dari inputValue
    int inputValueLength = inputValue.length;

    // Buat variabel bit48Prepaid berdasarkan panjang inputValue
    String bit48Prepaid;
    if (inputValueLength == 11) {
      bit48Prepaid = 'JTL53L3$inputValue' + '0000000000000';
    } else if (inputValueLength == 12) {
      bit48Prepaid = 'JTL53L300000000000$inputValue' + '1';
    } else {
      throw Exception('Panjang inputValue tidak valid');
    }

    // Elemen-elemen ISO message
    String mti = "0200";
    String bit2 = "53502"; //ubah 53501 postpaid //53504 nontaglis
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
    String bit42 = "201000145100000031";
    String bit48 = bit48Prepaid; // Input pelanggan
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
      // Hubungkan ke server
      final socket = await Socket.connect('168.168.10.175', 7100)
          .timeout(Duration(seconds: 5), onTimeout: () {
        throw Exception('Gagal terkoneksi dengan server');
      });
      print('Connected to the server.');

      // Kirim ISO message
      socket.write(isoMessage);
      await socket.flush();
      print('ISO message sent.');

      // Buffer untuk menerima respons dari server
      final responseBuffer = StringBuffer();

      // Mendengarkan respons dari server
      await socket.listen(
        (data) {
          // Tambahkan data yang diterima ke buffer
          String responseChunk = String.fromCharCodes(data);
          responseBuffer.write(responseChunk);
        },
        onDone: () {
          print(
              'Data fully received: ${responseBuffer.toString()}'); // Cetak respons penuh setelah selesai
        },
        onError: (error) {
          throw Exception('Gagal saat memproses data: $error');
        },
      ).asFuture();

      // Tutup koneksi setelah selesai
      await socket.close();

      // Jika respons kosong, lempar pengecualian
      if (responseBuffer.isEmpty) {
        throw Exception('Server tidak merespon');
      }

      // Kembalikan respons sebagai string
      return responseBuffer.toString();
    } catch (e) {
      // Hapus prefix "Exception: " dari pesan error
      String errorMessage = e.toString().replaceFirst("Exception: ", "");
      print('Terjadi kesalahan: $errorMessage');
      return 'Terjadi Kesalahan: $errorMessage';
    }
  }
}

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ISOMessageParsing {
  static List<String> bulanArray = [
    '',
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGS',
    'SEP',
    'OKT',
    'NOV',
    'DES'
  ];

  static List<dynamic>?
      result; // Variabel statis untuk menyimpan hasil parse Bit 48
  static List<dynamic>?
      result62; // Variabel statis untuk menyimpan hasil parse Bit 62

  // PROSES DEFINISIKAN ISO RESPONSE
  // PANJANG LOOPING SESUAI DENGAN PANJANG KARAKTER BIT48, TOTAL JUMLAH TAGIHAN
  Future<String> printResponse(String serverResponse, String idpel) async {
    try {
      print("Contoh Response: $serverResponse");
      // Tunggu hasil dari parseISOResponse yang bisa asinkron
      return await parseISOResponse(serverResponse, idpel);
    } catch (e) {
      // return e.toString();
      return "Terjadi Kesalahan, Silahkan Coba Lagi";
    }
  }

  // PROSES DEFINISIKAN SETIAP BIT
  static Future<String> parseISOResponse(
      String isoMessage, String idpel) async {
    String header = isoMessage.substring(0, 2);
    String mti = isoMessage.substring(2, 6);
    String primaryBitmapHex = isoMessage.substring(6, 22);
    String primaryBitmapBinary = hexToBinary(primaryBitmapHex);

    Map<int, int> bitLengths = {
      3: 6,
      4: 12,
      7: 10,
      11: 6,
      12: 6,
      13: 4,
      15: 4,
      18: 4,
      32: -1, // Panjang variabel
      37: 12,
      39: 2,
      41: 7,
      42: 16,
      48: -1, // Panjang variabel
      49: 3
    };

    int currentIndex = 22;
    String? bit39;
    String? bit48;
    String? bit62;

    for (int bit = 1; bit <= primaryBitmapBinary.length; bit++) {
      if (primaryBitmapBinary[bit - 1] == '1') {
        if (bit == 2 || bit == 32) {
          // Bits dengan panjang variabel
          int length =
              int.parse(isoMessage.substring(currentIndex, currentIndex + 2));
          currentIndex += 2; // Pindah ke data setelah length
          String value =
              isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
        } else if (bit == 39) {
          int length = bitLengths[bit]!;
          String value =
              isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          bit39 = value; // Simpan nilai Bit 39 ke variabel
        } else if (bit == 48) {
          // Bits dengan panjang variabel
          int length =
              int.parse(isoMessage.substring(currentIndex, currentIndex + 3));
          currentIndex += 3; // Pindah ke data setelah length
          String value =
              isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          bit48 = value; // Simpan nilai Bit 48 ke variabel
        } else if (bit == 62) {
          // Bits dengan panjang variabel
          int length =
              int.parse(isoMessage.substring(currentIndex, currentIndex + 3));
          currentIndex += 3; // Pindah ke data setelah length
          String value =
              isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          bit62 = value; // Simpan nilai Bit 48 ke variabel
        } else if (bitLengths.containsKey(bit)) {
          // Bits dengan panjang tetap
          int length = bitLengths[bit]!;
          String value =
              isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
        }
      }
    }

    if (bit39 != null) {
      return await processResponseCode(bit39, idpel, bit48, bit62);
    } else {
      return "Bit 39 tidak ditemukan.";
    }
  }

  static Future<String> processResponseCode(
      String bit39, String idpel, String? bit48, String? bit62) async {
    if (bit39 == '00') {
      if (bit48 != null) {
        List<dynamic> result = parseBit48(bit48, idpel);
        if (bit62 != null) {
          List<dynamic> result62 = parseBit62(bit62);
          List<int> dataPerulanganVal = result62[4];
          if (dataPerulanganVal != 0) {
            String perulangan = "";
            for (int i = 0; i < dataPerulanganVal.length; i++) {
              perulangan += "${dataPerulanganVal[i]}\n";
            }
            print(perulangan);
          }
          String idpel = result[0];
          String nama = result[1];
          String nometer = result[2];
          String tarif = result[3];
          int daya = result[4];

          // Store result in shared preferences for session
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('idpel', idpel);

          return "NAMA: $nama\n"
              "NO. METER: $nometer\n"
              "TARIF/DAYA: $tarif/$daya";
        } else {
          return "Terjadi Kesalahan: Terjadi Kegagalan Saat Cek Data";
        }
      } else {
        return "Terjadi Kesalahan: Terjadi Kegagalan Saat Cek Data";
      }
    } else {
      switch (bit39) {
        case '09':
          return 'Terjadi Kesalahan: NO. METER / IDPEL YANG ANDA MASUKAN SALAH, MOHON TELITI KEMBALI';
        // Handle other error codes here...
        default:
          return "Terjadi Kesalahan: Kode Bit 39 tidak dikenali.";
      }
    }
  }

  static List<dynamic> parseBit48(String bit48, String idpel) {
    int currentIndex = 0;
    currentIndex += 7;
    String nometer = bit48.substring(currentIndex, currentIndex + 11);
    currentIndex += 11;
    String idpel = bit48.substring(currentIndex, currentIndex + 12);
    currentIndex += 12;
    currentIndex += 1;
    currentIndex += 32;
    currentIndex += 32;
    String nama = bit48.substring(currentIndex, currentIndex + 25);
    currentIndex += 25;
    String tarif = bit48.substring(currentIndex, currentIndex + 4).trim();
    currentIndex += 4;
    String daya = bit48.substring(currentIndex, currentIndex + 9);
    currentIndex += 9;
    String dayaClean = daya.replaceFirst(RegExp(r'^0+'), '');
    int dayaVal = int.parse(dayaClean);

    return [idpel, nama, nometer, tarif, dayaVal];
  }

  static List<dynamic> parseBit62(String bit62) {
    int currentIndex = 0;
    String kodeDist = bit62.substring(currentIndex, currentIndex + 2);
    currentIndex += 2;
    String kodeUnit = bit62.substring(currentIndex, currentIndex + 5);
    currentIndex += 5;
    String telpUnit = bit62.substring(currentIndex, currentIndex + 15);
    currentIndex += 15;
    String totalUnsold = bit62.substring(currentIndex, currentIndex + 6);
    currentIndex += 6;
    String totalUnsoldClean = totalUnsold == '000000' ? '0' : totalUnsold.replaceFirst(RegExp(r'^0+'), '');
    int totalUnsoldVal = int.parse(totalUnsoldClean);

    List<String> dataPerulangan = [];
    List<int> dataPerulanganVal = [];
    if (totalUnsoldVal != 0) {
      for (int i = 0; i < totalUnsoldVal; i++) {
        String data = bit62.substring(currentIndex, currentIndex + 11);
        currentIndex += 11;
        dataPerulangan.add(data);
        String dataPerulanganclean =
            dataPerulangan[i].replaceFirst(RegExp(r'^0+'), '');
        int dataPerulanganValitem = int.parse(dataPerulanganclean);
        dataPerulanganVal.add(dataPerulanganValitem);
      }
    } else {
      dataPerulanganVal.add(0);
    }

    return [kodeDist, kodeUnit, telpUnit, totalUnsoldVal, dataPerulanganVal];
  }

  static String hexToBinary(String hex) {
    StringBuffer binary = StringBuffer();
    for (int i = 0; i < hex.length; i++) {
      int decimal = int.parse(hex[i], radix: 16);
      String binarySegment = decimal.toRadixString(2).padLeft(4, '0');
      binary.write(binarySegment);
    }
    return binary.toString();
  }
}

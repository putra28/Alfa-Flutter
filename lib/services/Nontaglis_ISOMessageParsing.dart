import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ISOMessageParser.dart';
import 'ISOBitmapParsing.dart';

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
      result;

  Future<String> printResponse(String idpel) async {
    try {
      // IDPEL 5363112222200 (13)
      String serverResponse =
          "XX0210723A40010AC180000553504380000000000394800010210133500743410133501020103602116ALN32SATPZ01P33300000000000100"+
          "54ALF0012010001451000001875363112222200MIGRASI PRABAYAR         2025010120250131536610029023DEV SAT NONTAGLIS 00     "+
          "3D0F8E779B3F48C986E9DF2BA59F48182ALF210Z9C00B6FFABEC00000000039480000000000000394800000000000000360";
      
      return await parseISOResponse(serverResponse, idpel);
    } catch (e) {
      return "Terjadi Kesalahan, Silahkan Coba Lagi";
    }
  }

  static String? extractBit62Message(String isoMessage) {
    try {
      // Find position of "360" marker
      int marker = isoMessage.indexOf("360");
      if (marker == -1) return null;

      // Extract length (3 characters after "360")
      String lengthStr = isoMessage.substring(marker + 3, marker + 6);
      int length = int.tryParse(lengthStr) ?? 0;
      if (length == 0) return null;

      // Extract message based on length
      String message = isoMessage.substring(marker + 6, marker + 6 + length);
      return message;
    } catch (e) {
      return null;
    }
  }

  static Future<String> parseISOResponse(
    String isoMessage, String idpel) async {
    try{
      // Initialize bitmap parser
      Isobitmapparsing.initialize(128);
      // Parse the message using ISOMessageParser
      ParsedMessage parsedMessage = ISOMessageParser.parseMessage(isoMessage);
      // Print all parsed fields for debugging
      // print("=== Parsed ISO Message Fields ===");
      // print(ISOMessageParser.formatParsedMessage(parsedMessage));
      // Find bit 39 (response code) and bit 48 (additional data)
      String? bit39;
      String? bit48;
      String? bit62;
      for (ParsedField field in parsedMessage.fields) {
        if (field.bit == 39) {
          bit39 = field.value;
        } else if (field.bit == 48) {
          bit48 = field.value;
        } else if (field.bit == 62) {
          bit62 = field.value;
        }
      }
      if (bit39 != null) {
        if (bit39 != "00" && bit62 != null) {
          return "Terjadi Kesalahan: $bit62";
        }
        return await processResponseCode(bit39, idpel, bit48, 0, isoMessage);
      } else {
        return "Bit 39 tidak ditemukan.";
      }
    } catch (e) {
      String? errorMessage = extractBit62Message(isoMessage);
      if (errorMessage != null) {
        return "Terjadi Kesalahan: $errorMessage";
      }
      return "Terjadi Kesalahan: Format ISO Message tidak valid";
    }
  }

  // PROSES PARSING BIT48 DAN RETURN VALUE
  static List<dynamic> NontaglisParseBit48(String bit48, String idpel) {
    // print("Parsing Bit 48:");
    int currentIndex = 0;

    // 1. No Registrasi (13 karakter)
    String noRegistrasi = bit48.substring(currentIndex, currentIndex + 13);
    currentIndex += 13;
    // 2. transaksi (25 karakter)
    String transaksi = bit48.substring(currentIndex, currentIndex + 25);
    currentIndex += 25;

    // 3. TGLRegistrasi (8 karakter)
    String tglRegistrasi = bit48.substring(currentIndex, currentIndex + 8);
    currentIndex += 8;

    // 4. TGLExpire (8 karakter)
    String tglExpire = bit48.substring(currentIndex, currentIndex + 8);
    currentIndex += 8;

    // 5. IDPEL (8 karakter)
    String idPelanggan = bit48.substring(currentIndex, currentIndex + 12);
    currentIndex += 12;

    // 6. IDPEL (8 karakter)
    String nama = bit48.substring(currentIndex, currentIndex + 25);
    currentIndex += 25;

    // 7. PLNREF (8 karakter)
    String PLNREF = bit48.substring(currentIndex, currentIndex + 32);
    currentIndex += 32;

    // 8. SCREF (8 karakter)
    String SCREF = bit48.substring(currentIndex, currentIndex + 20);
    currentIndex += 20;

    // 9. TotalTagihan (8 karakter)
    String totalTagihanString =
        bit48.substring(currentIndex, currentIndex + 17).replaceFirst(RegExp(r'^0+'), '');
    int totalTagihan = int.parse(totalTagihanString) ~/ 100;
    currentIndex += 17;

    // 10. Tagihan (8 karakter)
    String TagihanString =
        bit48.substring(currentIndex, currentIndex + 17).replaceFirst(RegExp(r'^0+'), '');
    int intTagihan = int.parse(totalTagihanString) ~/ 100;
    currentIndex += 17;

    // 11. Admin (10 karakter)
    currentIndex += 10;
    int admin = 3500;

    String formattedAdmin =
        NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0)
            .format(admin);

    // parsedResult = "IDPEL : $idpel\n"
    //     "NAMA : $nama\n"
    //     "TOTAL LEMBAR TAGIHAN : $totalTagihan\n"
    //     "BL/TH : $periodeLooping\n"
    //     "RP TAG PLN : $formattedRPTAG\n"
    //     "ADMIN BANK : $formattedAdmin\n"
    //     "TOTAL : $formattedTotBay\n";

    // return parsedResult
    //     .trim(); // Menghilangkan spasi atau baris kosong di akhir
    return [
      noRegistrasi,
      transaksi,
      nama,
      totalTagihan,
      admin,
      idPelanggan,
      SCREF
    ];
  }

  static Future<String> processResponseCode(
      String bit39, String idpel, String? bit48, int latestCurrentIndex, String isoMessage) async {
    if (bit39 == '00') {
      if (bit48 != null) {
        List<dynamic> result = NontaglisParseBit48(bit48, idpel);
        String noRegistrasi = result[0];
        String transaksi = result[1];
        String nama = result[2];
        int totalTagihan = result[3];
        String formattedTotalTagihan = NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0).format(totalTagihan);
        int admin = result[4];
        String formattedAdmin = NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0).format(admin);
        String idPelanggan = result[5];
        int totalBayar = totalTagihan + admin;
        String formattedTotBay = NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0).format(totalBayar);
        String SCREF = result[6];

        // Store result in shared preferences for session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('idPelanggan', idPelanggan);
        await prefs.setString('SCREF', SCREF);
        await prefs.setInt('totalTagihan', totalTagihan);
        await prefs.setInt('totalBayar', totalBayar);
        await prefs.setInt('admin', admin);

        return """
NOMOR REGISTRASI  : $noRegistrasi
JENIS TRANSAKSI      : $transaksi
NAMA                      : $nama
RP. BAYAR                : $formattedTotalTagihan
ADMIN BANK            : $formattedAdmin
TOTAL BAYAR           : $formattedTotBay
""".trim();
      } else {
        return "Terjadi Kesalahan: Terjadi Kegagalan Saat Cek Response Code";
      }
    } else {
      return "Terjadi Kesalahan: Terjadi Kegagalan Saat Cek Data";
    }
  }
}

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

  // PROSES DEFINISIKAN ISO RESPONSE
  // PANJANG LOOPING SESUAI DENGAN PANJANG KARAKTER BIT48, TOTAL JUMLAH TAGIHAN
  Future<String> printResponse(String serverResponse, String idpel) async {
    try {
      // IDPEL 5363112222200 (13)
      // String serverResponse =
      //     "XX0210723A40010AC180000553504380000000000394800010210133500743410133501020103602116ALN32SATPZ01P33300000000000100"+
      //     "54ALF0012010001451000001875363112222200MIGRASI PRABAYAR         2025010120250131536610029023DEV SAT NONTAGLIS 00     "+
      //     "3D0F8E779B3F48C986E9DF2BA59F48182ALF210Z9C00B6FFABEC00000000039480000000000000394800000000000000360";
      // print("Contoh Response: $serverResponse");
      return await parseISOResponse(serverResponse, idpel);
    } catch (e) {
      // print("Failed to process response.");
      // print(e);
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

    // Data Elements
    int currentIndex = 22; // Setelah Primary Bitmap
    String? bit39; // Deklarasi untuk menyimpan Bit 39
    String? bit48; // Deklarasi untuk menyimpan Bit 48

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
          int length =
              int.parse(isoMessage.substring(currentIndex, currentIndex + 3));
          currentIndex += 3; // Pindah ke data setelah length
          String value =
              isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          bit48 = value; // Simpan nilai Bit 48 ke variabel
        } else if (bitLengths.containsKey(bit)) {
          // Bits dengan panjang tetap
          int length = bitLengths[bit]!;
          String value =
              isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
        }
      }
    }

    int latestCurrentIndex = currentIndex;

    // Proses Bit 39
    if (bit39 != null) {
      return await processResponseCode(
          bit39, idpel, bit48, latestCurrentIndex, isoMessage);
    } else {
      return "Bit 39 tidak ditemukan.";
    }
  }

  // PROSES PARSING BIT48 DAN RETURN VALUE
  static List<dynamic> parseBit48(String bit48, String idpel) {
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
      // Jika bit39 == '00', langsung kembalikan hasil dari parseBit48
      if (bit48 != null) {
        // return parseBit48(bit48, idpel);
        List<dynamic> result = parseBit48(bit48, idpel);
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

        return "NOMOR REGISTRASI: $noRegistrasi\n"
                "JENIS TRANSAKSI: $transaksi\n"
                "NAMA: $nama\n"
                "RP. BAYAR: $formattedTotalTagihan\n"
                "ADMIN BANK: $formattedAdmin\n"
                "TOTAL BAYAR: $formattedTotBay"
            .trim();
        // return "gacor lek ku";
        // return bit48;
      } else {
        // return "Bit 39 == 00 tetapi Bit 48 tidak tersedia.";
        return "Terjadi Kesalahan: Terjadi Kegagalan Saat Cek Data";
      }
    } else {
      int lengthBit62 = int.parse(
          isoMessage.substring(latestCurrentIndex, latestCurrentIndex + 3));
      latestCurrentIndex += 3; // Pindah ke data setelah length
      String value = isoMessage.substring(
          latestCurrentIndex, latestCurrentIndex + lengthBit62);
      latestCurrentIndex += lengthBit62;
      String bit62 = value; // Varible Message bit62
      return "Terjadi Kesalahan: $bit62";

      // switch (bit39) {
      //   case '14':
      //   case '77':
      //     return 'Terjadi Kesalahan: IDPEL YANG ANDA MASUKAN SALAH, MOHON TELITI KEMBALI';
      //   case '82':
      //     return 'Terjadi Kesalahan: TAGIHAN BULAN BERJALAN BELUM TERSEDIA';
      //   case '89':
      //     return 'Terjadi Kesalahan: PAYMENT MELEBIHI BATAS WAKTU YANG DITENTUKAN';
      //   case '90':
      //     return 'Terjadi Kesalahan: TRANSAKSI CUT OFF';
      //   case '63':
      //   case '16':
      //     return 'Terjadi Kesalahan: KONSUMEN IDPEL $idpel DIBLOKIR HUBUNGI PLN';
      //   case '34':
      //     return 'Terjadi Kesalahan: TAGIHAN SUDAH TERBAYAR';
      //   case '18':
      //     return 'Terjadi Kesalahan: TIMEOUT';
      //   case '48':
      //     return 'Terjadi Kesalahan: NOMOR REGISTRASI KADALUARSA, MOHON HUBUNGI PLN';
      //   default:
      //     return "Terjadi Kesalahan: Kode Bit 39 tidak dikenali.";
      // }
    }
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

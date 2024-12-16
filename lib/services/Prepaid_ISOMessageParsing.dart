import 'package:intl/intl.dart';

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

  // PROSES DEFINISIKAN ISO RESPONSE
  // PANJANG LOOPING SESUAI DENGAN PANJANG KARAKTER BIT48, TOTAL JUMLAH TAGIHAN
  String printResponse(String serverResponse, String idpel) {
    try {
      // String serverResponse =
      //     "XX0210723A40010AC180040553502380000000000000000121614585800743414585812161217602116ALN32SATPZ01P333000000000001" +
      //     "0054ALF001201000145100000" +
      //     "133JTL53L31410161770054211122882209362F3DDA3824510B3BF68DE226117952ALF210Z25355EED4B315710A05D1B2B" +
      //     "DEV SAT PREPAID          R3  0000077003600505454211               0000000000000000000000000000";
      // print("Contoh Response: $serverResponse");
      return parseISOResponse(serverResponse, idpel);
    } catch (e) {
      // print("Failed to process response.");
      // print(e);
      return e.toString();
    }
  }

  // PROSES DEFINISIKAN SETIAP BIT
  static String parseISOResponse(String isoMessage, String idpel) {
    String header = isoMessage.substring(0, 2);
    // MTI (4 karakter pertama)
    String mti = isoMessage.substring(2, 6);

    // Primary Bitmap (16 karakter setelah MTI)
    String primaryBitmapHex = isoMessage.substring(6, 22);

    // Convert Primary Bitmap to Binary
    String primaryBitmapBinary = hexToBinary(primaryBitmapHex);

    // Map untuk mendefinisikan panjang setiap bit
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
          // Bits dengan panjang variabel
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

    // Proses Bit 39
    if (bit39 != null) {
      return processResponseCode(bit39, idpel, bit48);
    } else {
      return "Bit 39 tidak ditemukan.";
    }
  }

  // PROSES PARSING BIT48 DAN RETURN VALUE
  static List<dynamic> parseBit48(String bit48, String idpel) {
    // print("Parsing Bit 48:");

    // Mulai parsing data berdasarkan struktur
    int currentIndex = 0;
    String parsedResult = '';

    // 1. ID Partner (7 karakter)
    currentIndex += 7;

    // 2. No. Meter (11 karakter)
    String nometer = bit48.substring(currentIndex, currentIndex + 11);
    currentIndex += 11;

    // 3. ID Pelanggan (12 Karakter)
    currentIndex += 12;

    // 4. Buy Option (1 Karakter)
    currentIndex += 1;

    // 5. PLN REF (32 Karakter)
    currentIndex += 32;

    // 6. SCREF (32 karakter)
    currentIndex += 32;

    // 7. Nama (25 karakter)
    String nama = bit48.substring(currentIndex, currentIndex + 25);
    currentIndex += 25;

    // 8. Tarif (4 Karakter)
    String tarif = bit48.substring(currentIndex, currentIndex + 4).trim();
    currentIndex += 4;

    // 9. Daya (9 Karakter)
    String daya = bit48.substring(currentIndex, currentIndex + 9);
    currentIndex += 9;
    
    // 10. Daya (contoh: 000007700)
    String dayaClean = daya.replaceFirst(RegExp(r'^0+'), '');
    int dayaVal = int.parse(dayaClean);

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
      nama,        // Nama pelanggan
      nometer,     // No. Meter
      tarif,       // Tarif
      dayaVal,     // Daya
    ];
  }

  static String processResponseCode(String bit39, String idpel, String? bit48) {
    if (bit39 == '00') {
      // Jika bit39 == '00', langsung kembalikan hasil dari parseBit48
      if (bit48 != null) {
        // return parseBit48(bit48, idpel);
        List<dynamic> result = parseBit48(bit48, idpel);
        String nama = result[0];
        String nometer = result[1];
        String tarif = result[2];
        int daya = result[3];
        return "NAMA: $nama\n"
               "NO. METER: $nometer\n"
               "TARIF/DAYA: $tarif/$daya";
          // return bit48;
      } else {
        // return "Bit 39 == 00 tetapi Bit 48 tidak tersedia.";
        return "Terjadi Kesalahan: Terjadi Kegagalan Saat Cek Data";
      }
    } else {
      // Kode yang ada sebelumnya
      switch (bit39) {
        case '09':
          return 'Terjadi Kesalahan: NO. METER / IDPEL YANG ANDA MASUKAN SALAH, MOHON TELITI KEMBALI';
        case '14':
          return 'Terjadi Kesalahan: IDPEL YANG ANDA MASUKAN SALAH, MOHON TELITI KEMBALI';
        case '47':
          return 'Terjadi Kesalahan: TOTAL KWH MELEBIHI BATAS MAKSIMUM';
        case '63':
        case '16':
          return 'Terjadi Kesalahan: KONSUMEN IDPEL $idpel DIBLOKIR HUBUNGI PLN';
        case '34':
          return 'Terjadi Kesalahan: TAGIHAN SUDAH TERBAYAR';
        case '77':
          return 'Terjadi Kesalahan: NO. METER YANG ANDA MASUKAN SALAH, MOHON TELITI KEMBALI';
        case '78':
          return 'Terjadi Kesalahan: NO. METER / IDPEL TIDAK DIIZINKAN UNTUK MELAKUKAN PEMBELIAN, SEGERA HUBUNGI PLN TERDEKAT';
        case '82':
          return 'Terjadi Kesalahan: TAGIHAN BELUM TERSEDIA';
        case '90':
          return 'Terjadi Kesalahan: TRANSAKSI CUT OFF';
        case '18':
          return 'Terjadi Kesalahan: TIMEOUT';
        default:
          return "Terjadi Kesalahan: Kode Bit 39 tidak dikenali.";
      }
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

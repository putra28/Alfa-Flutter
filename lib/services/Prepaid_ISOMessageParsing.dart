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
  String printResponse(String idpel) {
    try {
      String serverResponse =
          "XX0210723A40010AC180000514501380000000000100100111510495800743410495811151116602116ALN32SATPZ01P3330000000000010054ALF001201000145100000229" +
              "1738181571221002JTE210ZD9D542936A78FE11A4ECE07DDUMMY SAT PLN POSTPAID 2 17380               R1  000000900000000000" + //Awalan Bit 48
              "2024110000000000000000000000100100D00000000000000000000000000000000000068150000693300000000000000000000000000000000" + //Looping Tagihan
              // "2024100000000000000000000000200100D00000000000000000000000000000000000068150000693300000000000000000000000000000000" + //Looping Tagihan
              "360";
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
  static String parseBit48(String bit48, String idpel) {
    // print("Parsing Bit 48:");

    // Mulai parsing data berdasarkan struktur
    int currentIndex = 0;
    String parsedResult = '';

    // 1. ID Pelanggan (13 karakter)
    String idPelanggan = bit48.substring(currentIndex, currentIndex + 12);
    currentIndex += 12;

    // 2. Jumlah Tagihan (3 karakter)
    String jumlahTagihan = bit48.substring(currentIndex, currentIndex + 1);
    currentIndex += 1;
    int totalDataLooping = int.parse(jumlahTagihan);

    // 2. Jumlah Tagihan (3 karakter)
    String sisaTagihan = bit48.substring(currentIndex, currentIndex + 2);
    currentIndex += 2;

    // Jumlahkan Tagihan dengan sisa
    int totalTagihan = int.parse(jumlahTagihan) + int.parse(sisaTagihan);

    // 3. Scref (32 karakter)
    currentIndex += 32;

    // 4. Nama (20 karakter)
    String nama = bit48.substring(currentIndex, currentIndex + 25).trim();
    currentIndex += 25;

    // 5. Kode Unit (5 karakter)
    currentIndex += 5;

    // 6. Telepon Unit (16 karakter, jika kosong tetap dihitung)
    currentIndex += 15;

    // 7. Tarif (2 karakter)
    String tarif = bit48.substring(currentIndex, currentIndex + 4).trim();
    currentIndex += 4;

    // 8. Daya (9 karakter)
    String daya = bit48.substring(currentIndex, currentIndex + 9).trim()
          .replaceFirst(RegExp(r'^0+'), ''); // tanpa awalan nol;
    currentIndex += 9;

    // 9. Admin (9 karakter)
    // String admin = bit48.substring(currentIndex, currentIndex + 9);
    int admin = 2500;
    currentIndex += 9;
    // String cleanedAdmin = admin.replaceFirst(RegExp(r'^0+'), '');
    // String adminVal = cleanedAdmin.isNotEmpty ? cleanedAdmin : '0';

    // 9. Data Looping (115 karakter)
    List<String> dataLooping = [];
    for (int i = 0; i < totalDataLooping; i++) {
      String loopingData = bit48.substring(currentIndex, currentIndex + 115);
      dataLooping.add(loopingData);
      currentIndex += 115;
    }

    // Parsing setiap data looping
    int totalTagihanLooping =
        0; // Variabel untuk menjumlahkan semua tagihanlooping
    int totalDendaLooping = 0; // Variabel untuk menjumlahkan semua dendalooping
    for (String data in dataLooping) {
      String tagihanlooping = data
          .substring(22, 34)
          .replaceFirst(RegExp(r'^0+'), ''); // 12 karakter, tanpa awalan nol
      String dendalooping = data
          .substring(55, 67)
          .replaceFirst(RegExp(r'^0+'), ''); // 12 karakter, tanpa awalan nol
      if (dendalooping.isEmpty) {
        dendalooping = '0';
      }

      totalTagihanLooping +=
          int.parse(tagihanlooping); // Menjumlahkan tagihanlooping
      totalDendaLooping +=
          int.parse(dendalooping); // Menjumlahkan tagihanlooping
    }

    List<String> tahunList = dataLooping.map((e) => e.substring(0, 4)).toList();
    List<String> bulanList = dataLooping.map((e) => e.substring(4, 6)).toList();
    List<String> bulanNamaList =
        bulanList.map((e) => bulanArray[int.parse(e)]).toList();
    List<String> periodeLoopingList = List.generate(dataLooping.length,
        (index) => "${bulanNamaList[index]}${tahunList[index]}");
    // Menggabungkan elemen-elemen periodeLoopingList menjadi satu string dan menghapus karakter [ dan ]
    String periodeLooping =
        periodeLoopingList.toString().replaceAll(RegExp(r'[\[\]]'), '');
    int totalPeriodeLooping = periodeLoopingList.length;

    int totalAdmin = admin * totalPeriodeLooping;

    String formattedAdmin =
        NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0)
            .format(totalAdmin);

    // Hitung total dari semua tagihan dan denda looping
    int RPTagPLN = totalTagihanLooping + totalDendaLooping;
    String formattedRPTAG =
        NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0)
            .format(RPTagPLN);

    int totalBayar = RPTagPLN + totalAdmin;
    String formattedTotBay =
        NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0)
            .format(totalBayar);

    parsedResult = "IDPEL : $idpel\n"
        "NAMA : $nama\n"
        "TARIF/DAYA : $tarif/$daya\n";

    return parsedResult
        .trim(); // Menghilangkan spasi atau baris kosong di akhir
  }

  static String processResponseCode(String bit39, String idpel, String? bit48) {
    if (bit39 == '00') {
      // Jika bit39 == '00', langsung kembalikan hasil dari parseBit48
      if (bit48 != null) {
        return parseBit48(bit48, idpel);
        // return bit48;
      } else {
        // return "Bit 39 == 00 tetapi Bit 48 tidak tersedia.";
        return "Terjadi Kegagalan Saat Cek Data";
      }
    } else {
      // Kode yang ada sebelumnya
      switch (bit39) {
        case '09':
          return 'NO. METER / IDPEL YANG ANDA MASUKAN SALAH, MOHON TELITI KEMBALI';
        case '14':
          return 'IDPEL YANG ANDA MASUKAN SALAH, MOHON TELITI KEMBALI';
        case '47':
          return 'TOTAL KWH MELEBIHI BATAS MAKSIMUM';
        case '63':
        case '16':
          return 'KONSUMEN IDPEL $idpel DIBLOKIR HUBUNGI PLN';
        case '34':
          return 'TAGIHAN SUDAH TERBAYAR';
        case '77':
          return 'NO. METER YANG ANDA MASUKAN SALAH, MOHON TELITI KEMBALI';
        case '78':
          return 'NO. METER / IDPEL TIDAK DIIZINKAN UNTUK MELAKUKAN PEMBELIAN, SEGERA HUBUNGI PLN TERDEKAT';
        case '82':
          return 'TAGIHAN BELUM TERSEDIA';
        case '90':
          return 'TRANSAKSI CUT OFF';
        case '18':
          return 'TIMEOUT';
        default:
          return "Kode Bit 39 tidak dikenali.";
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

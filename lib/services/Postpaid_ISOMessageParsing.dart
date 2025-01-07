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

  static List<dynamic>?result;

  Future<String> printResponse(String serverResponse, String idpel) async {
    try {
      // IDPEL 173818157323
      // String serverResponse =
          // "XX0210723A40010AC180000514501380000000000100100111510495800743410495811151116602116ALN32SATPZ01P3330000000000010054ALF001201000145100000344" +
          //     "1738181571222002JTE210ZD9D542936A78FE11A4ECE07DDUMMY SAT PLN POSTPAID 2 17380               R1  000000900000000000" + //Awalan Bit 48
          //     "2024110000000000000000000000100100D00000000000000000000000000000000000068150000693300000000000000000000000000000000" + //Looping Tagihan
          //     "2024100000000000000000000000200100D00000000000000000000000000000000000068150000693300000000000000000000000000000000" + //Looping Tagihan
          //     "360";
      return await parseISOResponse(serverResponse, idpel);
    } catch (e) {
      return "Terjadi Kesalahan, Silahkan Coba Lagi";
    }
  }

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

    for (int bit = 1; bit <= primaryBitmapBinary.length; bit++) {
      if (primaryBitmapBinary[bit - 1] == '1') {
        if (bit == 2 || bit == 32) {
          int length = int.parse(isoMessage.substring(currentIndex, currentIndex + 2));
          currentIndex += 2; // Pindah ke data setelah length
          String value = isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
        } else if (bit == 39) {
          int length = bitLengths[bit]!;
          String value = isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          bit39 = value; // Simpan nilai Bit 39 ke variabel
        } else if (bit == 48) {
          int length = int.parse(isoMessage.substring(currentIndex, currentIndex + 3));
          currentIndex += 3; // Pindah ke data setelah length
          String value = isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          bit48 = value; // Simpan nilai Bit 48 ke variabel
        } else if (bitLengths.containsKey(bit)) {
          int length = bitLengths[bit]!;
          String value = isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
        }
      }
    }

    int latestCurrentIndex = currentIndex;

    if (bit39 != null) {
      return await processResponseCode(bit39, idpel, bit48, latestCurrentIndex, isoMessage);
    } else {
      return "Bit 39 tidak ditemukan.";
    }
  }

  // PROSES PARSING BIT48 DAN RETURN VALUE
  static List<dynamic> parseBit48(String bit48, String idpel) {
    int currentIndex = 0;

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
    String SCREF = bit48.substring(currentIndex, currentIndex + 32);
    currentIndex += 32;
    // 4. Nama (20 karakter)
    String nama = bit48.substring(currentIndex, currentIndex + 25).trim();
    currentIndex += 25;
    currentIndex += 5; // 5. Kode Unit (5 karakter)
    currentIndex += 15; // 6. Telepon Unit (16 karakter, jika kosong tetap dihitung)
    currentIndex += 4; // 7. Tarif (2 karakter)
    currentIndex += 9; // 8. Daya (9 karakter)
    // 9. Admin (9 karakter)
    int admin = 2500;
    currentIndex += 9;
    // String cleanedAdmin = admin.replaceFirst(RegExp(r'^0+'), '');
    // String adminVal = cleanedAdmin.isNotEmpty ? cleanedAdmin : '0';

    List<String> dataLooping = [];
    for (int i = 0; i < totalDataLooping; i++) {
      String loopingData = bit48.substring(currentIndex, currentIndex + 115);
      dataLooping.add(loopingData);
      currentIndex += 115;
    }

    int totalTagihanLooping = 0; // Variabel untuk menjumlahkan semua tagihanlooping
    int totalDendaLooping = 0; // Variabel untuk menjumlahkan semua dendalooping
    for (String data in dataLooping) {
      String tagihanlooping = data.substring(22, 34).replaceFirst(RegExp(r'^0+'), ''); // 12 karakter, tanpa awalan nol
      String dendalooping = data.substring(55, 67).replaceFirst(RegExp(r'^0+'), ''); // 12 karakter, tanpa awalan nol
      dendalooping = dendalooping.isEmpty ? '0' : dendalooping;
      totalTagihanLooping += int.parse(tagihanlooping);
      totalDendaLooping += int.parse(dendalooping);
    }

    List<String> tahunList = dataLooping.map((e) => e.substring(0, 4)).toList();
    List<String> bulanList = dataLooping.map((e) => e.substring(4, 6)).toList();
    List<String> bulanNamaList = bulanList.map((e) => bulanArray[int.parse(e)]).toList();
    List<String> periodeLoopingList = List.generate(dataLooping.length,(index) => "${bulanNamaList[index]}${tahunList[index]}");
    // Menggabungkan elemen-elemen periodeLoopingList menjadi satu string dan menghapus karakter [ dan ]
    String periodeLooping = periodeLoopingList.toString().replaceAll(RegExp(r'[\[\]]'), '');
    int totalPeriodeLooping = periodeLoopingList.length;
    int totalAdmin = admin * totalPeriodeLooping;
    int RPTagPLN = totalTagihanLooping + totalDendaLooping;
    int totalBayar = RPTagPLN + totalAdmin;

    String formattedAdmin = NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0).format(totalAdmin);
    String formattedRPTAG = NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0).format(RPTagPLN);
    String formattedTotBay = NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0).format(totalBayar);

    return [
      nama, // Nama pelanggan
      totalTagihan, // Total tagihan
      periodeLooping, // Periode looping (contoh: "JAN2024, FEB2024")
      formattedRPTAG, // Format rupiah untuk tagihan PLN
      formattedAdmin, // Format rupiah untuk admin bank
      formattedTotBay, // Format total bayar
      totalAdmin,
      RPTagPLN,
      totalBayar,
      idPelanggan,
      SCREF
    ];
  }

  static Future<String> processResponseCode(String bit39, String idpel,
      String? bit48, int latestCurrentIndex, String isoMessage) async {
    if (bit39 == '00') {
      if (bit48 != null) {
        List<dynamic> result = parseBit48(bit48, idpel);
        String nama = result[0];
        int totalTagihan = result[1];
        String periodeLooping = result[2];
        String formattedRPTAG = result[3];
        String formattedAdmin = result[4];
        String formattedTotBay = result[5];
        int totalAdmin = result[6];
        int RPTagPLN = result[7];
        int totalBayar = result[8];
        String idPelanggan = result[9];
        String SCREF = result[10];

        // Store result in shared preferences for session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('nama', nama);
        await prefs.setInt('totalTagihan', totalTagihan);
        await prefs.setInt('totalAdmin', totalAdmin);
        await prefs.setInt('RPTagPLN', RPTagPLN);
        await prefs.setInt('totalBayar', totalBayar);
        await prefs.setString('idPelanggan', idPelanggan);
        await prefs.setString('SCREF', SCREF);

        return "IDPEL         : $idPelanggan\n"
                "NAMA         : $nama\n"
                "TOTAL TAGIHAN: $totalTagihan\n"
                "BL/TH        : $periodeLooping\n"
                "RP TAG PLN   : $formattedRPTAG\n"
                "ADMIN BANK   : $formattedAdmin\n"
                "TOTAL BAYAR  : $formattedTotBay"
            .trim();
      } else {
        return "Terjadi Kesalahan: Terjadi Kegagalan Saat Cek Data";
      }
    } else {
      int lengthBit62 = int.parse(isoMessage.substring(latestCurrentIndex, latestCurrentIndex + 3));
      latestCurrentIndex += 3; 
      String bit62 = isoMessage.substring(latestCurrentIndex, latestCurrentIndex + lengthBit62);
      latestCurrentIndex += lengthBit62;
      return "Terjadi Kesalahan: $bit62";
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

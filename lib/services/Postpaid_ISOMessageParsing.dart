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

  static List<dynamic>? result;

  Future<String> printResponse(String idpel) async {
    try {
      String serverResponse =
          "XX0210723A40010AC180000514501380000000000100100111510495800743410495811151116602116ALN32SATPZ01P3330000000000010054ALF001201000145100000344" +
              "1738181571222002JTE210ZD9D542936A78FE11A4ECE07DDUMMY SAT PLN POSTPAID 2 17380               R1  000000900000000000" +
              "2024110000000000000000000000100100D00000000000000000000000000000000000068150000693300000000000000000000000000000000" +
              "2024100000000000000000000000200100D00000000000000000000000000000000000068150000693300000000000000000000000000000000" +
              "360";
          // "XX0210623A40010AC080040514501380000010213095400743413095401020103602116ALN32SATPZ01P3330000000000011454ALF001201000145100000360053IDPEL YANG ANDA MASUKKAN SALAH, MOHON TELITI KEMBALI."; // bit 62
          // "XX0210623A40010AC080040514501380000010615511400743415511401060107602116ALN32SATPZ01P333000000000001345145100000360023TAGIHAN SUDAH TERBAYAR.";
          // "XX0210623A40010AC080040514501380000000000000000010309513500743409513501030104602116ALN32SATPZ01P3330000000000010554ALF001201000145100000360024KONEKSI KE SERVER GAGAL.";
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
    try {
      // Initialize bitmap parser
      Isobitmapparsing.initialize(128);

      // Parse the message using ISOMessageParser
      ParsedMessage parsedMessage = ISOMessageParser.parseMessage(isoMessage);

      // Print all parsed fields for debugging
      print("=== Parsed ISO Message Fields ===");
      print(ISOMessageParser.formatParsedMessage(parsedMessage));

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

  // Keep the existing parseBit48 method unchanged as it handles specific business logic

  static List<dynamic> parseBit48(String bit48, String idpel) {
    // Existing parseBit48 implementation remains the same
    int currentIndex = 0;

    String idPelanggan = bit48.substring(currentIndex, currentIndex + 12);
    currentIndex += 12;
    String jumlahTagihan = bit48.substring(currentIndex, currentIndex + 1);
    currentIndex += 1;
    int totalDataLooping = int.parse(jumlahTagihan);
    String sisaTagihan = bit48.substring(currentIndex, currentIndex + 2);
    currentIndex += 2;
    int totalTagihan = int.parse(jumlahTagihan) + int.parse(sisaTagihan);
    String SCREF = bit48.substring(currentIndex, currentIndex + 32);
    currentIndex += 32;
    String nama = bit48.substring(currentIndex, currentIndex + 25).trim();
    currentIndex += 25;
    currentIndex += 5; // Kode Unit
    currentIndex += 15; // Telepon Unit
    currentIndex += 4; // Tarif
    currentIndex += 9; // Daya
    int admin = 2500;
    currentIndex += 9;

    List<String> dataLooping = [];
    for (int i = 0; i < totalDataLooping; i++) {
      String loopingData = bit48.substring(currentIndex, currentIndex + 115);
      dataLooping.add(loopingData);
      currentIndex += 115;
    }

    int totalTagihanLooping = 0;
    int totalDendaLooping = 0;
    for (String data in dataLooping) {
      String tagihanlooping =
          data.substring(22, 34).replaceFirst(RegExp(r'^0+'), '');
      String dendalooping =
          data.substring(55, 67).replaceFirst(RegExp(r'^0+'), '');
      dendalooping = dendalooping.isEmpty ? '0' : dendalooping;
      totalTagihanLooping += int.parse(tagihanlooping);
      totalDendaLooping += int.parse(dendalooping);
    }

    List<String> tahunList = dataLooping.map((e) => e.substring(0, 4)).toList();
    List<String> bulanList = dataLooping.map((e) => e.substring(4, 6)).toList();
    List<String> bulanNamaList =
        bulanList.map((e) => bulanArray[int.parse(e)]).toList();
    List<String> periodeLoopingList = List.generate(dataLooping.length,
        (index) => "${bulanNamaList[index]}${tahunList[index]}");
    String periodeLooping =
        periodeLoopingList.toString().replaceAll(RegExp(r'[\[\]]'), '');
    int totalPeriodeLooping = periodeLoopingList.length;
    int totalAdmin = admin * totalPeriodeLooping;
    int RPTagPLN = totalTagihanLooping + totalDendaLooping;
    int totalBayar = RPTagPLN + totalAdmin;

    final currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp.', decimalDigits: 0);
    String formattedAdmin = currencyFormatter.format(totalAdmin);
    String formattedRPTAG = currencyFormatter.format(RPTagPLN);
    String formattedTotBay = currencyFormatter.format(totalBayar);

    return [
      nama,
      totalTagihan,
      periodeLooping,
      formattedRPTAG,
      formattedAdmin,
      formattedTotBay,
      totalAdmin,
      RPTagPLN,
      totalBayar,
      idPelanggan,
      SCREF
    ];
  }

  // Keep the existing processResponseCode method with minimal changes
  static Future<String> processResponseCode(String bit39, String idpel,
      String? bit48, int latestCurrentIndex, String isoMessage) async {
    if (bit48 != null) {
      List<dynamic> result = parseBit48(bit48, idpel);

      // Store result in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nama', result[0]);
      await prefs.setInt('totalTagihan', result[1]);
      await prefs.setInt('totalAdmin', result[6]);
      await prefs.setInt('RPTagPLN', result[7]);
      await prefs.setInt('totalBayar', result[8]);
      await prefs.setString('idPelanggan', result[9]);
      await prefs.setString('SCREF', result[10]);

      return """
IDPEL                 : ${result[9]}
NAMA                : ${result[0]}
TOTAL TAGIHAN  : ${result[1]}
BL/TH                : ${result[2]}
RP TAG PLN        : ${result[3]}
ADMIN BANK      : ${result[4]}
TOTAL BAYAR     : ${result[5]}
"""
          .trim();
    } else {
      return "Terjadi Kesalahan: Terjadi Kegagalan Saat Cek Data";
    }
  }
}

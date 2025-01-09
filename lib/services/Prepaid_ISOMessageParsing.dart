import 'dart:convert';
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
      result; // Variabel statis untuk menyimpan hasil parse Bit 48
  static List<dynamic>?
      result62; // Variabel statis untuk menyimpan hasil parse Bit 62

  Future<String> printResponse(String idpel) async {
    try {
      // IDPEL 542111228822
      String serverResponse =
          "XX0210723A40010AC180040553502380000000000000000121816015700743416015712181219602116ALN32SATPZ01P333000000000001"+
          "0054ALF001201000145100000"+
          "133JTL53L31410161770054211122882209362F3DDA3824510B3BF68DE226117952ALF210Z25355EED4B315710A05D1B2BDEV SAT PREPAID          R3  000007700360"+
          "0505454211               0000020000050000000000200000";
          // 0000020000050000000000200000
          // 0000000000000000000000000000
      return await parseISOResponse(serverResponse, idpel);
    } catch (e) {
      // return e.toString();
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
        return await processResponseCode(bit39, idpel, bit48, bit62, 0, isoMessage);
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

static Future<void> processPerulangan(List<int> dataPerulanganVal) async {
  if (dataPerulanganVal.isNotEmpty) {
    // Create denomUnsold array
    List<Map<String, dynamic>> denomUnsold = [];
    Map<int, String> itemValueToIdMap = {
      20000: "20Rb USLD",
      50000: "50Rb USLD",
      100000: "100Rb USLD",
      200000: "200Rb USLD",
      500000: "500Rb USLD",
      1000000: "1Jt USLD",
      5000000: "5Jt USLD",
      10000000: "10Jt USLD",
      50000000: "50Jt USLD",
    };

    for (int value in dataPerulanganVal) {
      String? itemid = itemValueToIdMap[value];
      if (itemid != null) {
        denomUnsold.add({"itemid": itemid, "itemvalue": value});
      }
    }

    // Save denomUnsold to session
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('denomUnsold', jsonEncode(denomUnsold));

    // Print the result for debugging
    print(jsonEncode(denomUnsold));
  } else {
    print("dataPerulanganVal is empty.");
  }
}
  static Future<String> processResponseCode(
      String bit39, String idpel, String? bit48, String? bit62, int latestCurrentIndex, String isoMessage) async {
    if (bit39 == '00') {
      if (bit48 != null) {
        List<dynamic> result = PrepaidParseBit48(bit48, idpel);
        if (bit62 != null) {
          List<dynamic> result62 = parseBit62(bit62);
          List<int> dataPerulanganVal = result62[4];
          if (dataPerulanganVal.isNotEmpty) {
          try {
              List<int> denomPerulanganVal = dataPerulanganVal.where((value) => value != null).toList();

              await processPerulangan(denomPerulanganVal);
            } catch (e) {
              print("Error processing denom values: $e");
            }
          }
          // if (dataPerulanganVal != 0) {
          //   String perulangan = "";
          //   for (int i = 0; i < dataPerulanganVal.length; i++) {
          //     perulangan += "${dataPerulanganVal[i]}\n";
          //   }
          //   List<int> denomPerulanganVal = perulangan.split("\n").map(int.parse).toList();
          //   print(perulangan);
          //   await processPerulangan(denomPerulanganVal);
          // }
          
          String idpel = result[0];
          String nama = result[1];
          String nometer = result[2];
          String tarif = result[3];
          int daya = result[4];
          String SCREF = result[5];

          // Store result in shared preferences for session
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('idpel', idpel);
          await prefs.setString('SCREF', SCREF);

          return """
NAMA           : $nama
NO. METER    : $nometer
TARIF/DAYA   : $tarif/$daya
          """;
        } else {
          return "Terjadi Kesalahan: Terjadi Kegagalan Saat Cek Data";
        }
      } else {
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
    }
  }

  static List<dynamic> PrepaidParseBit48(String bit48, String idpel) {
    int currentIndex = 0;
    currentIndex += 7;
    String nometer = bit48.substring(currentIndex, currentIndex + 11);
    currentIndex += 11;
    String idpel = bit48.substring(currentIndex, currentIndex + 12);
    currentIndex += 12;
    currentIndex += 1;
    currentIndex += 32;
    String SCREF = bit48.substring(currentIndex, currentIndex + 32);
    currentIndex += 32;
    String nama = bit48.substring(currentIndex, currentIndex + 25);
    currentIndex += 25;
    String tarif = bit48.substring(currentIndex, currentIndex + 4).trim();
    currentIndex += 4;
    String daya = bit48.substring(currentIndex, currentIndex + 9);
    currentIndex += 9;
    String dayaClean = daya.replaceFirst(RegExp(r'^0+'), '');
    int dayaVal = int.parse(dayaClean);

    return [idpel, nama, nometer, tarif, dayaVal, SCREF];
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
    String totalUnsoldClean = totalUnsold == '000000'
        ? '0'
        : totalUnsold.replaceFirst(RegExp(r'^0+'), '');
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
}

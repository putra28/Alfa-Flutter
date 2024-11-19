import 'dart:convert';

class ISOMessageParsing {
  static void main() {
    printResponse();
  }

  static void printResponse() {
    try {
      String contohResponse =
          "0210723A40010AC180000514501380000000000100100111510495800743410495811151116602116ALN32SATPZ01P3330000000000010054ALF0012010001451000002291738181571221002JTE210ZD9D542936A78FE11A4ECE07DDUMMY SAT PLN POSTPAID 2 17380               R1  0000009000000000002024110000000000000000000000100100D00000000000000000000000000000000000068150000693300000000000000000000000000000000360";
      print("Contoh Response: $contohResponse");

      parseISOResponse(contohResponse);
    } catch (e) {
      print("Failed to process response.");
      print(e);
    }
  }

  static void parseISOResponse(String isoMessage) {
    // MTI (4 karakter pertama)
    String mti = isoMessage.substring(0, 4);
    print("MTI: $mti");

    // Primary Bitmap (16 karakter setelah MTI)
    String primaryBitmapHex = isoMessage.substring(4, 20);
    print("Primary Bitmap (Hex): $primaryBitmapHex");

    // Convert Primary Bitmap to Binary
    String primaryBitmapBinary = hexToBinary(primaryBitmapHex);
    print("Primary Bitmap (Binary): $primaryBitmapBinary");

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
    int currentIndex = 20; // Setelah Primary Bitmap
    for (int bit = 1; bit <= primaryBitmapBinary.length; bit++) {
      if (primaryBitmapBinary[bit - 1] == '1') {
        if (bit == 2 || bit == 32) {
          // Bits dengan panjang variabel
          int length = int.parse(isoMessage.substring(currentIndex, currentIndex + 2));
          currentIndex += 2; // Pindah ke data setelah length
          String value = isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          print("Bit $bit: $value (Length: $length)");
        } else if (bit == 48) {
          // Bits dengan panjang variabel
          int length = int.parse(isoMessage.substring(currentIndex, currentIndex + 3));
          currentIndex += 3; // Pindah ke data setelah length
          String value = isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          print("Bit $bit: $value (Length: $length)");
        } else if (bitLengths.containsKey(bit)) {
          // Bits dengan panjang tetap
          int length = bitLengths[bit]!;
          String value = isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          print("Bit $bit: $value");
        }
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

void main() {
  ISOMessageParsing.main();
}

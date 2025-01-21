//ISOBitmapParsing.dart
import 'ISOBitActive.dart';

class Isobitmapparsing {
  static final ISOBitActive _dataTipes = ISOBitActive();
  static late List<ISOBitActive> _fieldData;

  // Initialize the field data
  static void initialize(int length) {
    _fieldData = ISOBitActive.ISOResetBit(length);
  }

  // Konversi hex ke binary
  static String _hexToBinary(String hex) {
    if (hex.length % 2 != 0) {
      hex = '0' + hex;
    }

    String binary = '';
    for (int i = 0; i < hex.length; i += 2) {
      String hexByte = hex.substring(i, i + 2);
      int decimal = int.parse(hexByte, radix: 16);
      String binaryByte = decimal.toRadixString(2).padLeft(8, '0');
      binary += binaryByte;
    }
    return binary;
  }

  // Mendapatkan list bit yang aktif beserta length-nya
  static List<Map<String, dynamic>> getActiveBitsWithLength(String bitmap) {
    List<Map<String, dynamic>> activeBitsInfo = [];
    String binary = _hexToBinary(bitmap);

    for (int i = 0; i < binary.length; i++) {
      if (binary[i] == '1') {
        int bitPosition = i + 1;
        if (bitPosition < _fieldData.length) {
          ISOBitActive fieldInfo = _fieldData[bitPosition];
          activeBitsInfo.add({
            'bit': bitPosition,
            'length': fieldInfo.length,
            'type': fieldInfo.type,
            'format': fieldInfo.format
          });
        }
      }
    }

    return activeBitsInfo;
  }

  // Method untuk validasi bitmap
  static bool isValidBitmap(String bitmap) {
    if (bitmap.isEmpty) return false;
    final RegExp hexRegExp = RegExp(r'^[0-9A-Fa-f]+$');
    if (!hexRegExp.hasMatch(bitmap)) return false;
    if (bitmap.length != 16) return false;
    return true;
  }

  // Method untuk print bit yang aktif dengan length
  static String printActiveBitsWithLength(String bitmap) {
    if (!isValidBitmap(bitmap)) {
      return 'Invalid bitmap format';
    }

    List<Map<String, dynamic>> activeBitsInfo = getActiveBitsWithLength(bitmap);
    List<String> output = [];

    for (var bitInfo in activeBitsInfo) {
      output.add("${bitInfo['bit']}(length: ${bitInfo['length']})");
    }

    return 'Active bits: ${output.join(", ")}';
  }

  // Method untuk mendapatkan detail lengkap bit yang aktif
  static String getDetailedActiveBits(String bitmap) {
    if (!isValidBitmap(bitmap)) {
      return 'Invalid bitmap format';
    }

    List<Map<String, dynamic>> activeBitsInfo = getActiveBitsWithLength(bitmap);
    StringBuffer output = StringBuffer();
    output.writeln('Detailed Active Bits Information:');
    output.writeln('-' * 50);

    for (var bitInfo in activeBitsInfo) {
      output.writeln('Bit ${bitInfo['bit']}:\n'
          '  Length: ${bitInfo['length']}\n'
          '  Type: ${bitInfo['type']}\n'
          '  Format: ${bitInfo['format']}\n');
    }

    return output.toString();
  }
}

// Example usage:
void main() {
  String bitmap = "623A40010AC08004";

  // Initialize dengan panjang array yang cukup (misalnya 128 untuk primary + secondary bitmap)
  Isobitmapparsing.initialize(128);

  if (Isobitmapparsing.isValidBitmap(bitmap)) {
    // Print format sederhana
    // print(Isobitmapparsing.printActiveBitsWithLength(bitmap));

    // Print format detail
    // print(Isobitmapparsing.getDetailedActiveBits(bitmap));
  } else {
    // print('Invalid bitmap format');
  }
}

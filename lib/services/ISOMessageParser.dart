//ISOMessageParser.dart
import 'ISOBitmapParsing.dart';
import 'Postpaid_ISOMessageParsing.dart';
import 'Prepaid_ISOMessageParsing.dart';
import 'Nontaglis_ISOMessageParsing.dart';

// Class untuk menyimpan hasil parsing
class ParsedField {
  final int bit;
  final String value;
  final int length;

  ParsedField(this.bit, this.value, this.length);

  @override
  String toString() {
    return 'Bit $bit (length: $length): $value';
  }
}

// Struktur untuk menyimpan hasil parsing message
class ParsedMessage {
  final String header;
  final String mti;
  final String bitmap;
  final List<ParsedField> fields;
  final String IDPelanggan;

  ParsedMessage(
      this.header, this.mti, this.bitmap, this.fields, this.IDPelanggan);
}

class ISOMessageParser {
  static final Isobitmapparsing _bitmapParser = Isobitmapparsing();
  static ParsedMessage parseMessage(String message) {
    String IDpel = "173818157323";
    int position = 0;

    // Parse header (2 karakter)
    String header = message.substring(position, position + 2);
    position += 2;

    // Parse MTI (4 karakter)
    String mti = message.substring(position, position + 4);
    position += 4;

    // Parse bitmap (16 karakter hex)
    String bitmap = message.substring(position, position + 16);
    position += 16;

    // Get active bits dengan length information
    List<Map<String, dynamic>> activeBits =
        Isobitmapparsing.getActiveBitsWithLength(bitmap);
    List<ParsedField> parsedFields = [];
    String? bit48Value; // Untuk menyimpan nilai bit 39

    // Parse setiap field berdasarkan bitmap
    for (var bitInfo in activeBits) {
      int bit = bitInfo['bit'];
      String format = bitInfo['format'];
      int defaultLength = bitInfo['length'];

      // Handle variable length fields
      int actualLength;
      String value;

      if (format == "LLVAR" || format == "LLLVAR") {
        // Baca length indicator
        int lengthIndicatorSize = format == "LLVAR" ? 2 : 3;
        String lengthIndicator =
            message.substring(position, position + lengthIndicatorSize);
        actualLength = int.parse(lengthIndicator);
        position += lengthIndicatorSize;

        // Baca value berdasarkan length indicator
        value = message.substring(position, position + actualLength);
        position += actualLength;
      } else {
        // Fixed length fields
        actualLength = defaultLength;
        value = message.substring(position, position + actualLength);
        position += actualLength;
      }

      parsedFields.add(ParsedField(bit, value, actualLength));

      // Simpan nilai bit 48 jika ditemukan
      if (bit == 48) {
        bit48Value = value;
      }
    }

    return ParsedMessage(header, mti, bitmap, parsedFields, IDpel);
  }

  static String formatParsedMessage(ParsedMessage parsedMessage) {
    StringBuffer output = StringBuffer();

    output.writeln('Header: ${parsedMessage.header}');
    output.writeln('MTI: ${parsedMessage.mti}');
    output.writeln('Bitmap: ${parsedMessage.bitmap}');
    output.writeln('ID Pelanggan: ${parsedMessage.IDPelanggan}');

    for (var field in parsedMessage.fields) {
      output.writeln(
          'Bit ${field.bit} (length: ${field.length}): ${field.value}');
    }

    return output.toString();
  }
}

// Usage example:
void main() {
  // Initialize bitmap parser
  Isobitmapparsing.initialize(128);

  // Sample ISO message
  String isoMessage =
      // "XX0210723A40010AC180000514501380000000000100100111510495800743410495811151116602116ALN32SATPZ01P3330000000000010054ALF001201000145100000344" +
      //     "1738181571222002JTE210ZD9D542936A78FE11A4ECE07DDUMMY SAT PLN POSTPAID 2 17380               R1  000000900000000000" + //Awalan Bit 48
      //     "2024110000000000000000000000100100D00000000000000000000000000000000000068150000693300000000000000000000000000000000" + //Looping Tagihan
      //     "2024100000000000000000000000200100D00000000000000000000000000000000000068150000693300000000000000000000000000000000" + //Looping Tagihan
      //     "360";
  "XX0210623A40010AC080040514501380000010615511400743415511401060107602116ALN32SATPZ01P333000000000001345145100000360023TAGIHAN SUDAH TERBAYAR."; // bit 62

  try {
    var parsedMessage = ISOMessageParser.parseMessage(isoMessage);
    // print(ISOMessageParser.formatParsedMessage(parsedMessage));
  } catch (e) {
    // print('Error parsing message: $e');
  }
}

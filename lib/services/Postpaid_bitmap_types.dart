// lib/services/postpaid_bitmap_types.dart

class PostpaidBitmapTypes {
  // Fungsi untuk mengolah bitmap menjadi data tipe postpaid
  static String postpaidBitmapDataTypes(int bitmap, List<String> bitmaps) {
    String outResponse;
    try {
      String dataBitmap = "";
      int intPos = 0;
      int intBitmap = 0;
      String tmpBitmap = "0" * bitmap;
      String tmpBitmap2;

      // Mengisi tmpBitmap berdasarkan array bitmaps
      for (String s in bitmaps) {
        int index = int.parse(s) - 1;
        tmpBitmap = tmpBitmap.substring(0, index) + "1" + tmpBitmap.substring(index + 1);
      }

      // Memproses tmpBitmap dalam kelompok 4 bit
      do {
        tmpBitmap2 = tmpBitmap.substring(intPos, intPos + 4);
        intBitmap = 0;

        // Menghitung nilai intBitmap berdasarkan bit yang ada
        if (tmpBitmap2[0] == '1') {
          intBitmap += 8;
        }
        if (tmpBitmap2[1] == '1') {
          intBitmap += 4;
        }
        if (tmpBitmap2[2] == '1') {
          intBitmap += 2;
        }
        if (tmpBitmap2[3] == '1') {
          intBitmap += 1;
        }

        // Mengonversi intBitmap ke bentuk hex atau angka
        dataBitmap += switch (intBitmap) {
          10 => "A",
          11 => "B",
          12 => "C",
          13 => "D",
          14 => "E",
          15 => "F",
          _ => intBitmap.toString(),
        };

        intPos += 4;
      } while (intPos < bitmap);

      outResponse = dataBitmap;
    } catch (exception) {
      throw Exception("Error processing bitmap: $exception");
    }
    return outResponse;
  }
}

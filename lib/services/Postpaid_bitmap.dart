// lib/services/postpaid_bitmap.dart
import 'Postpaid_bitmap_types.dart';

class PostpaidBitmap {
  // Fungsi untuk membangun bitmap
  static String buildIsoBitmap() {
    // Daftar bitmaps aktif (misalnya field 1, 2, 3, dst aktif)
    List<String> activeBitmaps = [
      "2",
      "3",
      "7",
      "11",
      "12",
      "13",
      "15",
      "18",
      "32",
      "37",
      "41",
      "42",
      "48",
      "49"
    ];

    // Tentukan panjang bitmap yang digunakan dalam pesan ISO 8583 (biasanya 128 bit)
    int bitmapLength = 64; // 128-bit untuk ISO8583, bisa diubah jika diperlukan

    // Gunakan fungsi dari PostpaidBitmapTypes untuk membangun bitmap
    return PostpaidBitmapTypes.postpaidBitmapDataTypes(
        bitmapLength, activeBitmaps);
  }
}

void main() {
  // Bangun bitmap sesuai dengan field aktif
  String isoBitmap = PostpaidBitmap.buildIsoBitmap();

  // Cetak bitmap dalam format hexadecimal
  print("ISO Bitmap: $isoBitmap");
}

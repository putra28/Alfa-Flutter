class ISOMessageParsing {
  String printResponse(String idpel) {
    try {
      String contohResponse =
          "0210723A40010AC180000514501380000000000100100111510495800743410495811151116602116ALN32SATPZ01P3330000000000010054ALF0012010001451000002291738181571221002JTE210ZD9D542936A78FE11A4ECE07DDUMMY SAT PLN POSTPAID 2 17380               R1  0000009000000000002024110000000000000000000000100100D00000000000000000000000000000000000068150000693300000000000000000000000000000000360";
      // print("Contoh Response: $contohResponse");
      return parseISOResponse(contohResponse, idpel);
    } catch (e) {
      // print("Failed to process response.");
      // print(e);
      return 'Failed to Process';
    }
  }

  static String parseISOResponse(String isoMessage, String idpel) {
    // MTI (4 karakter pertama)
    String mti = isoMessage.substring(0, 4);
    // print("MTI: $mti");

    // Primary Bitmap (16 karakter setelah MTI)
    String primaryBitmapHex = isoMessage.substring(4, 20);
    // print("Primary Bitmap (Hex): $primaryBitmapHex");

    // Convert Primary Bitmap to Binary
    String primaryBitmapBinary = hexToBinary(primaryBitmapHex);
    // print("Primary Bitmap (Binary): $primaryBitmapBinary");

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
          // print("Bit $bit: $value (Length: $length)");
        } else if (bit == 39) {
          int length = bitLengths[bit]!;
          String value =
              isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          bit39 = value; // Simpan nilai Bit 39 ke variabel
          // bit39 = '14';
          // print("Bit $bit: $value");
        } else if (bit == 48) {
          // Bits dengan panjang variabel
          int length =
              int.parse(isoMessage.substring(currentIndex, currentIndex + 3));
          currentIndex += 3; // Pindah ke data setelah length
          String value =
              isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          bit48 = value; // Simpan nilai Bit 48 ke variabel
          // print("Bit $bit: $value (Length: $length)");
        } else if (bitLengths.containsKey(bit)) {
          // Bits dengan panjang tetap
          int length = bitLengths[bit]!;
          String value =
              isoMessage.substring(currentIndex, currentIndex + length);
          currentIndex += length;
          // print("Bit $bit: $value");
        }
      }
    }

    // Proses Bit 39
    if (bit39 != null) {
      return processResponseCode(bit39, idpel, bit48);
    } else {
      // print("Bit 39 tidak ditemukan.");
      return "Bit 39 tidak ditemukan.";
    }
  }

  static String parseBit48(String bit48) {
    // print("Parsing Bit 48:");

    // Mulai parsing data berdasarkan struktur
    int currentIndex = 0;
   String parsedResult = '';

    // 1. ID Pelanggan (13 karakter)
    String idPelanggan = bit48.substring(currentIndex, currentIndex + 12);
    currentIndex += 12;
    parsedResult += "$idPelanggan idpel\n";
    // print("$idPelanggan idpel");

    // 2. Jumlah Tagihan (3 karakter)
    String jumlahTagihan = bit48.substring(currentIndex, currentIndex + 3);
    currentIndex += 3;
    parsedResult += "$jumlahTagihan jumlahTagihan\n";
    // print("$jumlahTagihan jml tagihan");

    // 3. Scref (32 karakter)
    String scref = bit48.substring(currentIndex, currentIndex + 32);
    currentIndex += 32;
    parsedResult += "$scref scref\n";
    // print("$scref scref");

    // 4. Nama (20 karakter)
    String nama = bit48.substring(currentIndex, currentIndex + 25).trim();
    currentIndex += 25;
    parsedResult += "$nama nama\n";
    // print("$nama nama");

    // 5. Kode Unit (5 karakter)
    String kodeUnit = bit48.substring(currentIndex, currentIndex + 5);
    currentIndex += 5;
    // print("$kodeUnit kode unit");

    // 6. Telepon Unit (16 karakter, jika kosong tetap dihitung)
    String teleponUnit =
        bit48.substring(currentIndex, currentIndex + 15).trim();
    currentIndex += 15;
    // print("$teleponUnit telepon unit");

    // 7. Tarif (2 karakter)
    String tarif = bit48.substring(currentIndex, currentIndex + 4).trim();
    currentIndex += 4;
    // print("$tarif tarif");

    // 8. Daya (9 karakter)
    String daya = bit48.substring(currentIndex, currentIndex + 9);
    currentIndex += 9;
    // print("$daya daya");

    // 9. Admin (9 karakter)
    String admin = bit48.substring(currentIndex, currentIndex + 9);
    currentIndex += 9;
    // print("$admin admin");

    // 10. Periode (6 karakter)
    String periode = bit48.substring(currentIndex, currentIndex + 6);
    currentIndex += 6;
    // print("$periode periode");

    // 11. Tanggal Akhir (8 karakter)
    String tanggalAkhir = bit48.substring(currentIndex, currentIndex + 8);
    currentIndex += 8;
    // print("$tanggalAkhir tgl akhir");

    // 12. Tanggal Baca (8 karakter)
    String tanggalBaca = bit48.substring(currentIndex, currentIndex + 8);
    currentIndex += 8;
    // print("$tanggalBaca tgl baca");

    // 13. Tagihan (12 karakter)
    String tagihan = bit48.substring(currentIndex, currentIndex + 12);
    currentIndex += 12;
    // print("$tagihan tagihan");

    // 14. Kode Insentif (1 karakter)
    String kodeInsentif = bit48.substring(currentIndex, currentIndex + 1);
    currentIndex += 1;
    // print("$kodeInsentif kode insentif");

    // 15. Insentif (10 karakter)
    String insentif = bit48.substring(currentIndex, currentIndex + 10);
    currentIndex += 10;
    // print("$insentif insentif");

    // 16. Pajak (10 karakter)
    String pajak = bit48.substring(currentIndex, currentIndex + 10);
    currentIndex += 10;
    // print("$pajak tax");

    // 17. Denda (12 karakter)
    String denda = bit48.substring(currentIndex, currentIndex + 12);
    currentIndex += 12;
    // print("$denda denda");

    // 18. Stand 1 Awal (8 karakter)
    String stand1Awal = bit48.substring(currentIndex, currentIndex + 8);
    currentIndex += 8;
    // print("$stand1Awal stand1 awal");

    // 19. Stand 1 Akhir (8 karakter)
    String stand1Akhir = bit48.substring(currentIndex, currentIndex + 8);
    currentIndex += 8;
    // print("$stand1Akhir stand1 akhir");

    // 20. Stand 2 Awal (8 karakter)
    String stand2Awal = bit48.substring(currentIndex, currentIndex + 8);
    currentIndex += 8;
    // print("$stand2Awal stand2 awal");

    // 21. Stand 2 Akhir (8 karakter)
    String stand2Akhir = bit48.substring(currentIndex, currentIndex + 8);
    currentIndex += 8;
    // print("$stand2Akhir stand2 akhir");

    // 22. Reff 1 (10 karakter)
    String reff1 = bit48.substring(currentIndex, currentIndex + 10);
    currentIndex += 10;
    // print("$reff1 reff 1");

    // 23. Reff 2 (10 karakter)
    String reff2 = bit48.substring(currentIndex, currentIndex + 10);
    currentIndex += 10;
    // print("$reff2 reff 2");

    // 24. Reff 3 (10 karakter)
    String reff3 = bit48.substring(currentIndex, currentIndex + 10);
    currentIndex += 10;
    // print("$reff3 reff 3");
    return parsedResult;
  }

  static String processResponseCode(String bit39, String idpel, String? bit48) {
    if (bit39 == '00') {
      // Jika bit39 == '00', langsung kembalikan hasil dari parseBit48
      if (bit48 != null) {
        parseBit48(bit48);
        return "Bit 39 == 00, Bit 48 diproses.";
      } else {
        return "Bit 39 == 00 tetapi Bit 48 tidak tersedia.";
      }
    } else {
      // Kode yang ada sebelumnya
      switch (bit39) {
        case '14':
          return 'IDPEL YANG ANDA MASUKAN SALAH, MOHON TELITI KEMBALI';
        case '82':
          return 'TAGIHAN BULAN BERJALAN BELUM TERSEDIA';
        case '90':
          return 'TRANSAKSI CUT OFF';
        case '63':
        case '16':
          return 'KONSUMEN IDPEL $idpel DIBLOKIR HUBUNGI PLN';
        case '34':
          return 'TAGIHAN SUDAH TERBAYAR';
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

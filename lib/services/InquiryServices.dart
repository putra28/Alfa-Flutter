import 'dart:io';

final String baseIP = "169.169.10.175";
final int basePort = 7005; //7101

class InquiryServices {
  Future<String> sendISOMessage(String isoMessage) async {
    try {
      final socket = await Socket.connect(baseIP, basePort) 
          .timeout(Duration(seconds: 5), onTimeout: () {
        throw Exception('Gagal terkoneksi dengan server');
      });
  
      socket.write(isoMessage);
      await socket.flush();
  
      final responseBuffer = StringBuffer();
  
      await socket.listen(
        (data) {
          String responseChunk = String.fromCharCodes(data);
          responseBuffer.write(responseChunk);
          // print(
          //     'Server Response: $responseChunk\n'); // Cetak data yang diterima (chunk)
        },
        onDone: () {
          // print(
          //     'Data fully received: ${responseBuffer.toString()}'); // Cetak respons penuh setelah selesai
        },
        onError: (error) {
          throw Exception('Gagal saat memproses data: $error');
        },
      ).asFuture();
  
      await socket.close();
  
      if (responseBuffer.isEmpty) {
        throw Exception('Server tidak merespon');
      }
  
      return responseBuffer.toString();
    } catch (e) {
      String errorMessage = e.toString().replaceFirst("Exception: ", "");
      return 'Terjadi Kesalahan: $errorMessage';
    }
  }
}

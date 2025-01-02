import 'dart:io';

class InquiryServices {
  Future<String> sendISOMessage(String isoMessage) async {
    try {
      final socket = await Socket.connect('168.168.10.175', 7005) //7101
          .timeout(Duration(seconds: 5), onTimeout: () {
        throw Exception('Gagal terkoneksi dengan server');
      });
      print('Connected to the server.');
  
      socket.write(isoMessage);
      await socket.flush();
      print('ISO message sent.');
  
      final responseBuffer = StringBuffer();
  
      await socket.listen(
        (data) {
          String responseChunk = String.fromCharCodes(data);
          responseBuffer.write(responseChunk);
          print(
              'Received chunk: $responseChunk\n'); // Cetak data yang diterima (chunk)
        },
        onDone: () {
          print(
              'Data fully received: ${responseBuffer.toString()}'); // Cetak respons penuh setelah selesai
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
      print('Terjadi kesalahan: $errorMessage');
      return 'Terjadi Kesalahan: $errorMessage';
    }
  }
}

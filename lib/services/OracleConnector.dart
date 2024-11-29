import 'package:dart_odbc/dart_odbc.dart';

void main() async {
  // Koneksi string ODBC menggunakan TNS
  String dsn = 'Driver={Oracle in OraClient11g_home1};Dbq=LIM_DEVEL;Uid=ALFA;Pwd=TERANOVA;';
  
  // Koneksi ke database
  OdbcConnection conn = await OdbcConnection.connect(dsn);
  
  // Cek koneksi
  if (conn.isConnected) {
    print('Koneksi berhasil!');
    
    // Jalankan query
    String query = 'SELECT * FROM M_NOANTRIAN';
    var results = await conn.query(query);
    
    // Menampilkan hasil query
    for (var row in results) {
      print(row);  // Menampilkan setiap baris hasil
    }
    
    // Tutup koneksi
    await conn.close();
  } else {
    print('Gagal terhubung ke database.');
  }
}

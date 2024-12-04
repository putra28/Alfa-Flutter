from flask import Flask, jsonify, request
from datetime import datetime
import cx_Oracle

app = Flask(__name__)

# Konfigurasi database berdasarkan TNS
dsn = cx_Oracle.makedsn(
    "168.168.168.172",  # Host Oracle
    1522,               # Port Oracle
    service_name="DEVEL"  # Service name dari TNS
)

username = "ALFA"
password = "TERANOVA"

# @app.route('/api/test-connection', methods=['GET'])
# def test_connection():
#     try:
#         # Membuka koneksi ke database
#         connection = cx_Oracle.connect(user=username, password=password, dsn=dsn)
#         # Tes query sederhana
#         cursor = connection.cursor()
#         cursor.execute("SELECT 'Connected to Oracle!' AS message FROM dual")
#         result = cursor.fetchone()
#         # Tutup koneksi
#         cursor.close()
#         connection.close()

#         return jsonify({"status": "success", "message": result[0]})
#     except cx_Oracle.DatabaseError as e:
#         error, = e.args
#         return jsonify({"status": "error", "message": error.message})
        
@app.route('/api/insert-antrian', methods=['POST'])
def insert_noantrian():
    try:
        # Ambil data dari request body JSON
        payload = request.get_json()
        method = payload.get('method')
        data = payload.get('data')

        # Validasi method
        if not method or not data:
            return jsonify({"status": "error", "message": "Parameter 'method' dan 'data' harus diisi!"}), 400

        # Ambil data dari 'data' JSON
        idtoko = data.get('var_idtoko')
        amount = data.get('var_amount')
        idpel = data.get('var_idpel')
        rptag = data.get('var_rptag')
        admttl = data.get('var_admttl')
        lop = data.get('var_lembar')

        # Validasi data input
        if not all([idtoko, amount, idpel, rptag, admttl, lop]):
            return jsonify({"status": "error", "message": "Semua parameter di dalam 'data' harus diisi!"}), 400

        # Membuka koneksi ke database
        connection = cx_Oracle.connect(user=username, password=password, dsn=dsn)
        cursor = connection.cursor()

        # Pilih SQL berdasarkan method
        if method == "Antrian Postpaid":
            sql = """
            INSERT INTO M_NOANTRIAN (
                TANGGAL, KDTOKO, PRODUCT_ID, DENOM_ID, AMOUNT, NOANTRIAN, IDPEL, TAGIHAN, ADMIN, LBR
            ) 
            SELECT 
                TO_CHAR(SYSDATE,'YYYYMMDD') TGL,
                :idtoko KDTOKO,
                '11101' PRODUCT_ID,
                '0' DENOM_ID,
                :amount AMOUNT,
                (SELECT DECODE(Q1.NOANTRIAN, '', 1, Q1.NOANTRIAN + 1) NOANTRIAN
                 FROM (
                     SELECT SUM(1) NOANTRIAN 
                     FROM M_NOANTRIAN
                     WHERE TANGGAL = TO_CHAR(SYSDATE,'YYYYMMDD') AND KDTOKO = :idtoko
                 ) Q1) NOANTRIAN,
                :idpel IDPEL,
                :rptag TAGIHAN,
                :admttl ADMIN,
                :lop LBR
            FROM DUAL
            """
        elif method == "Antrian Prepaid":
            sql = """
            -- Contoh SQL untuk Antrian Prepaid (saat ini sama)
            INSERT INTO M_NOANTRIAN (
                TANGGAL, KDTOKO, PRODUCT_ID, DENOM_ID, AMOUNT, NOANTRIAN, IDPEL, TAGIHAN, ADMIN, LBR
            ) 
            SELECT 
                TO_CHAR(SYSDATE,'YYYYMMDD') TGL,
                :idtoko KDTOKO,
                '22201' PRODUCT_ID,
                '1' DENOM_ID,
                :amount AMOUNT,
                (SELECT DECODE(Q1.NOANTRIAN, '', 1, Q1.NOANTRIAN + 1) NOANTRIAN
                 FROM (
                     SELECT SUM(1) NOANTRIAN 
                     FROM M_NOANTRIAN
                     WHERE TANGGAL = TO_CHAR(SYSDATE,'YYYYMMDD') AND KDTOKO = :idtoko
                 ) Q1) NOANTRIAN,
                :idpel IDPEL,
                :rptag TAGIHAN,
                :admttl ADMIN,
                :lop LBR
            FROM DUAL
            """
        elif method == "Antrian Nontaglis":
            sql = """
            -- Contoh SQL untuk Antrian Nontaglis (saat ini sama)
            INSERT INTO M_NOANTRIAN (
                TANGGAL, KDTOKO, PRODUCT_ID, DENOM_ID, AMOUNT, NOANTRIAN, IDPEL, TAGIHAN, ADMIN, LBR
            ) 
            SELECT 
                TO_CHAR(SYSDATE,'YYYYMMDD') TGL,
                :idtoko KDTOKO,
                '33301' PRODUCT_ID,
                '2' DENOM_ID,
                :amount AMOUNT,
                (SELECT DECODE(Q1.NOANTRIAN, '', 1, Q1.NOANTRIAN + 1) NOANTRIAN
                 FROM (
                     SELECT SUM(1) NOANTRIAN 
                     FROM M_NOANTRIAN
                     WHERE TANGGAL = TO_CHAR(SYSDATE,'YYYYMMDD') AND KDTOKO = :idtoko
                 ) Q1) NOANTRIAN,
                :idpel IDPEL,
                :rptag TAGIHAN,
                :admttl ADMIN,
                :lop LBR
            FROM DUAL
            """
        else:
            return jsonify({"status": "error", "message": "Method tidak dikenali!"}), 400

        # Eksekusi SQL
        cursor.execute(sql, {
            'idtoko': idtoko,
            'amount': amount,
            'idpel': idpel,
            'rptag': rptag,
            'admttl': admttl,
            'lop': lop
        })
        connection.commit()

        # Tutup koneksi
        cursor.close()
        connection.close()

        return jsonify({
            "status": "success",
            "message": f"Data berhasil disimpan dengan method {method}!",
            "datetime": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        })

    except cx_Oracle.DatabaseError as e:
        error, = e.args
        return jsonify({
            "status": "error",
            "message": error.message,
            "datetime": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        }), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=2882)

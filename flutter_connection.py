from flask import Flask, jsonify, request, Response 
from datetime import datetime
from collections import OrderedDict
import cx_Oracle
import json

app = Flask(__name__)

# Konfigurasi database berdasarkan TNS
dsn = cx_Oracle.makedsn(
    "168.168.168.172",  # Host Oracle
    1522,               # Port Oracle
    service_name="DEVEL"  # Service name dari TNS
)

username = "ALFA"
password = "TERANOVA"

@app.route('/api/link-alfa', methods=['POST'])
def link_alfa():
    try:
        # Ambil data dari request body JSON
        payload = request.get_json()
        method = payload.get('method')
        data = payload.get('data')

        # Ambil data dari 'data' JSON
        kdtoko = data.get('var_kdtoko')
        denom = data.get('var_denom')
        amount = data.get('var_amount')
        idpel = data.get('var_idpel')
        rptag = data.get('var_rptag')
        admttl = data.get('var_admttl')
        lop = data.get('var_lembar')

        # Validasi data input untuk Postpaid dan Prepaid
        if method == "Insert Antrian Postpaid":
            required_params = ['var_kdtoko', 'var_amount', 'var_idpel', 'var_rptag', 'var_admttl', 'var_lembar']
            for param in required_params:
                if param not in data:
                    return jsonify({"status": "error", "message": f"Parameter '{param}' harus diisi untuk Postpaid!"}), 400
        elif method == "Insert Antrian Prepaid":
            required_params = ['var_kdtoko', 'var_denom', 'var_idpel', 'var_admttl']
            for param in required_params:
                if param not in data:
                    return jsonify({"status": "error", "message": f"Parameter '{param}' harus diisi untuk Prepaid!"}), 400
        elif method == "Get Denom Prepaid":
            required_params = ['var_kdtoko']
            for param in required_params:
                if param not in data:
                    return jsonify({"status": "error", "message": f"Parameter '{param}' harus diisi untuk Prepaid!"}), 400
        else:
            return jsonify({"status": "error", "message": "Method tidak dikenali!"}), 400

        # Membuka koneksi ke database
        connection = cx_Oracle.connect(user=username, password=password, dsn=dsn)
        cursor = connection.cursor()

        # SQL untuk Postpaid
        if method == "Insert Antrian Postpaid":
            sql = """
            INSERT INTO M_NOANTRIAN (
                TANGGAL, KDTOKO, PRODUCT_ID, DENOM_ID, AMOUNT, NOANTRIAN, IDPEL, TAGIHAN, ADMIN, LBR
            ) 
            SELECT 
                TO_CHAR(SYSDATE, 'YYYYMMDD') TGL,
                :kdtoko KDTOKO,
                '11101' PRODUCT_ID,
                '0' DENOM_ID,
                :amount AMOUNT,
                (SELECT DECODE(Q1.NOANTRIAN, '', 1, Q1.NOANTRIAN + 1) NOANTRIAN
                 FROM (
                     SELECT SUM(1) NOANTRIAN 
                     FROM M_NOANTRIAN
                     WHERE TANGGAL = TO_CHAR(SYSDATE, 'YYYYMMDD') AND KDTOKO = :kdtoko
                 ) Q1) NOANTRIAN,
                :idpel IDPEL,
                :rptag TAGIHAN,
                :admttl ADMIN,
                :lop LBR
            FROM DUAL
            """

            cursor.execute(sql, {
                'kdtoko': kdtoko,
                'amount': amount,
                'idpel': idpel,
                'rptag': rptag,
                'admttl': admttl,
                'lop': lop
            })

        # SQL untuk Prepaid
        elif method == "Insert Antrian Prepaid":
            sql = """
            INSERT INTO M_NOANTRIAN (
                TANGGAL, KDTOKO, PRODUCT_ID, DENOM_ID, AMOUNT, NOANTRIAN, IDPEL, TAGIHAN, ADMIN, LBR
            )
            SELECT 
                TO_CHAR(SYSDATE, 'YYYYMMDD') TGL,
                :kdtoko KDTOKO,
                '11102' PRODUCT_ID,
                :denom DENOM_ID,
                :denom AMOUNT,
                (SELECT DECODE(Q1.NOANTRIAN, '', 1, Q1.NOANTRIAN + 1) NOANTRIAN 
                 FROM (
                     SELECT SUM(1) NOANTRIAN 
                     FROM M_NOANTRIAN 
                     WHERE TANGGAL = TO_CHAR(SYSDATE, 'YYYYMMDD') AND KDTOKO = :kdtoko
                 ) Q1) NOANTRIAN,
                :idpel IDPEL,
                :rptag TAGIHAN,
                :admttl ADMIN,
                '1' LBR
            FROM DUAL
            """

            rptag = denom - admttl  # Menghitung rptag berdasarkan denom dan admttl
            cursor.execute(sql, {
                'kdtoko': kdtoko,
                'denom': denom,
                'idpel': idpel,
                'rptag': rptag,
                'admttl': admttl
            })
        
        elif method == "Get Denom Prepaid":
            sql = """
            SELECT ITEMID, ITEMVALUE
            FROM M_SUBPRODUK
            """
            cursor.execute(sql)
            result = cursor.fetchall()

            # Format hasil ke dalam bentuk JSON
            denom_list = [{"itemid": row[0], "itemvalue": int(row[1])} for row in result]

            # Urutkan berdasarkan itemvalue dari terkecil ke terbesar
            denom_list_sorted = sorted(denom_list, key=lambda x: x['itemvalue'])

            # Tutup koneksi
            cursor.close()
            connection.close()

            denom_response = OrderedDict({
                "status": "success",
                "message": "Data denom berhasil diambil dan diurutkan.",
                "datetime": datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                "data": denom_list_sorted,
            })
            
            denom_json = json.dumps(denom_response, ensure_ascii=False, indent=4)
            return Response(denom_json, content_type='application/json', status=200)

        # Commit perubahan
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

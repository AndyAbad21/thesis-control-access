from flask import Flask, request, jsonify
import pyotp
from datetime import datetime
import time
import sqlite3
from werkzeug.security import check_password_hash
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Para permitir llamadas desde Flutter (front-end)

DB_FILE = 'acceso_seguro.db'

def validar_usuario(email, password):
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute('SELECT password_hash FROM usuarios WHERE email = ?', (email,))
    row = cursor.fetchone()
    conn.close()

    if row is None:
        return False

    password_hash = row[0]
    return check_password_hash(password_hash, password)

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'status': 'error', 'message': 'Faltan datos'}), 400

    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute('SELECT id, password_hash, nombres, apellidos, secreto FROM usuarios WHERE email = ?', (email,))
    row = cursor.fetchone()
    conn.close()

    if row is None:
        return jsonify({'status': 'error', 'message': 'Usuario no encontrado'}), 401

    usuario_id, password_hash, nombres, apellidos, secreto = row

    if check_password_hash(password_hash, password):
        return jsonify({
            'status': 'success',
            'message': 'Login correcto',
            'usuario_id': usuario_id,
            'nombres': nombres,
            'apellidos': apellidos,
            'secreto': secreto
        })
    else:
        return jsonify({'status': 'error', 'message': 'Credenciales inválidas'}), 401


# Secreto compartido
OTP_DIGITS = 10
OTP_INTERVAL = 15  # ⚠️ Debe coincidir con el que usa Flutter
# Lista para almacenar eventos temporalmente en memoria
registros = []


@app.route('/validar-llave', methods=['POST'])
def validar_llave():
    data = request.get_json()
    llave = data.get('llave')
    usuario_id = data.get('usuario_id')

    print(f"🔑 [VALIDAR] Recibido -> usuario_id: {usuario_id}, llave: {llave}")

    # Obtener el secreto del usuario desde la base de datos
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute('SELECT secreto FROM usuarios WHERE id = ?', (usuario_id,))
    row = cursor.fetchone()
    conn.close()

    if row is None:
        return jsonify({'estado': 'denegado', 'message': 'Usuario no encontrado'}), 404

    secreto = row[0]  # Secreto almacenado en la base de datos

    # Generar el TOTP usando el secreto obtenido de la base de datos
    totp = pyotp.TOTP(
        secreto,  # Usar el secreto de la base de datos
        digits=OTP_DIGITS,
        interval=OTP_INTERVAL,
        digest='sha1'
    )
    otp_valida = totp.now()

    print(f"🔍 OTP esperada (servidor): {otp_valida}")

    if llave == otp_valida:
        estado = "autorizado"
    else:
        estado = "denegado"

    print(f"📣 [VALIDAR] Respuesta -> estado: {estado}")
    return jsonify({"estado": estado})


@app.route('/registrar-evento', methods=['POST'])
def registrar_evento():
    data = request.get_json()
    evento = {
        "usuario_id": data.get("usuario_id"),
        "fecha": data.get("fecha"),
        "estado": data.get("estado")
    }
    registros.append(evento)
    print(f"📝 [REGISTRO] Evento registrado -> {evento}")
    return jsonify({"mensaje": "evento registrado"})

@app.route('/eventos-acceso', methods=['GET'])
def eventos_acceso():
    print("📄 [CONSULTA] Enviando lista de eventos")
    return jsonify(registros)

if __name__ == '__main__':
    print("🚀 Backend Flask iniciado en http://0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000)

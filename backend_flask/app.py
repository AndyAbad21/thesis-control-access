from flask import Flask, request, jsonify
import pyotp
from datetime import datetime
import time

app = Flask(__name__)

# Secreto compartido
OTP_SECRET = "JBSWY3DPEHPK3PXP"
OTP_DIGITS = 10
OTP_ALG = "SHA1"
OTP_INTERVAL = 15  # ⚠️ Debe coincidir con el que usa Flutter

registros = []

@app.route('/validar-llave', methods=['POST'])
def validar_llave():
    data = request.get_json()
    llave = data.get('llave')
    usuario_id = data.get('usuario_id')

    print(f"🔑 [VALIDAR] Recibido -> usuario_id: {usuario_id}, llave: {llave}")

    # Generar TOTP en base al mismo secreto y configuración
    totp = pyotp.TOTP(
        OTP_SECRET,
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

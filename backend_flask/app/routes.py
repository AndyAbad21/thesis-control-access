# routes.py
from flask import Blueprint, request, jsonify
from .auth import validar_usuario
from .otp_validation import validar_llave
from .database import get_user_by_email
from datetime import datetime
import pyotp
import logging
import json

auth_bp = Blueprint("auth", __name__)

registros = []


# Ruta de login
@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.json
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        print(f"❌ Datos incompletos")
        return jsonify({"status": "error", "message": "Faltan datos"}), 400

    user = get_user_by_email(email)
    if user is None:
        print(
            f"📤 Login-Fail [Flask-->Flutter] El 📧 Email: {email} no esta asociado a ningun usuario de la UPS"
        )
        return jsonify({"status": "error", "message": "Usuario no encontrado"}), 401

    usuario_id, password_hash, nombres, apellidos, secreto = user

    print(
        f"🔐 Login [Autenticacion] Datos del usuario -> ( 👤 Email: {email}, 🔑 Contraseña: {password} )"
    )

    if validar_usuario(email, password):
        # Logs de login exitoso
        log_event(
            "INFO",
            "Login exitoso",
            {
                "userId": usuario_id,
                "nombres": nombres,
                "apellidos": apellidos,
                "secret": secreto,
                "ipAddress": request.remote_addr,
            },
        )

        return jsonify(
            {
                "status": "success",
                "message": "Login correcto",
                "usuario_id": usuario_id,
                "nombres": nombres,
                "apellidos": apellidos,
                "secreto": secreto,
            }
        )
    else:
        return jsonify({"status": "error", "message": "Credenciales inválidas"}), 401


# Ruta de validación de llave
@auth_bp.route("/validar-llave", methods=["POST"])
def validar_llave_route():
    data = request.get_json()
    llave = data.get("llave")
    usuario_id = data.get("usuario_id")

    print(f"🔑 [Esp32-->Flask] Recibido -> usuario_id: {usuario_id}, llave: {llave}")

    # Validar la OTP
    resultado = validar_llave(usuario_id, llave)

    print(f"📣 [Flask] Respuesta -> estado: {resultado['estado']}")
    return jsonify({"estado": resultado["estado"]})


# Ruta para registrar eventos
@auth_bp.route("/registrar-evento", methods=["POST"])
def registrar_evento():
    data = request.get_json()
    evento = {
        "usuario_id": data.get("usuario_id"),
        "fecha": datetime.now().strftime("%d/%m/%Y %H:%M:%S"),
        "estado": data.get("estado"),
    }
    # Para efectos de demostración solo agregamos en memoria
    registros.append(evento)
    print(f"📝 [REGISTRO] Evento registrado -> {evento}")
    return jsonify({"Flask": "evento registrado"})


# Ruta para consultar eventos
@auth_bp.route("/eventos-acceso", methods=["GET"])
def eventos_acceso():
    print("📄 [CONSULTA] Enviando lista de eventos")
    return jsonify(registros)


# Formato de los logs
def log_event(level, message, context=None):
    log = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "level": level,
        "message": message,
        "context": context or {},
    }
    print(json.dumps(log))

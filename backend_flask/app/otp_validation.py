# otp_validation.py
import pyotp
from .config import Config
from .database import get_user_secret_by_id

def validar_llave(usuario_id, llave):
    # Obtener el secreto del usuario desde la base de datos
    secreto_row = get_user_secret_by_id(usuario_id)
    
    if secreto_row is None:
        return {"estado": "denegado", "message": "Usuario no encontrado"}

    secreto = secreto_row['secreto']  # Secreto almacenado en la base de datos

    # Generar el TOTP usando el secreto obtenido de la base de datos
    totp = pyotp.TOTP(secreto, digits=Config.OTP_DIGITS, interval=Config.OTP_INTERVAL, digest='sha1')
    otp_valida = totp.now()

    if llave == otp_valida:
        estado = "autorizado"
    else:
        estado = "denegado"

    return {"estado": estado}

# config.py
import os

class Config:
    SECRET_KEY = os.urandom(24)  # Clave secreta para sesiones y cookies
    DB_FILE = 'acceso_seguro.db'  # Nombre de la base de datos
    OTP_DIGITS = 10               # Número de dígitos en el OTP
    OTP_INTERVAL = 15             # Intervalo de tiempo en segundos para OTP
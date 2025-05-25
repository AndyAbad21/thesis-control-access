# database.py
import sqlite3
from .config import Config

def get_db_connection():
    conn = sqlite3.connect(Config.DB_FILE)
    conn.row_factory = sqlite3.Row
    return conn

def get_user_by_email(email):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT id, password_hash, nombres, apellidos, secreto FROM usuarios WHERE email = ?', (email,))
    row = cursor.fetchone()
    conn.close()
    return row

def get_user_secret_by_id(usuario_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT secreto FROM usuarios WHERE id = ?', (usuario_id,))
    row = cursor.fetchone()
    conn.close()
    return row

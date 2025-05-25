import sqlite3
from werkzeug.security import generate_password_hash

DB_FILE = 'acceso_seguro.db'

def crear_base_y_tabla():
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            nombres TEXT,
            apellidos TEXT,
            secreto TEXT NOT NULL,
            fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    conn.commit()
    conn.close()
    print("Base de datos y tabla creadas correctamente.")

def insertar_usuario(email, password, nombres=None, apellidos=None, secreto=None):
    password_hash = generate_password_hash(password)

    if secreto is None:
        secreto = 'JBSWY3DPEHPK3PXP'  # Puedes cambiar este valor por defecto

    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()

    try:
        cursor.execute('''
            INSERT INTO usuarios (email, password_hash, nombres, apellidos, secreto) 
            VALUES (?, ?, ?, ?, ?)
        ''', (email, password_hash, nombres, apellidos, secreto))
        conn.commit()
        print(f"Usuario {email} insertado correctamente.")
    except sqlite3.IntegrityError:
        print(f"El usuario {email} ya existe.")
    finally:
        conn.close()

if __name__ == '__main__':
    crear_base_y_tabla()

    # Insertar usuarios de prueba con secretos
    insertar_usuario('aabadf@est.ups.edu.ec', 'contrasena123', 'Andy Fabricio', 'Abad Freire', 'JBSWY3DPEHPK3PXQ')
    insertar_usuario('dcpinab@est.ups.edu.ec', 'contrasena123', 'Domenica Caronila', 'Piña Baculima', 'JBSWY3DPEHPK3HTK')

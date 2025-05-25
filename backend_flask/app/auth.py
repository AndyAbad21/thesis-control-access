# auth.py
from werkzeug.security import check_password_hash
from .database import get_user_by_email

def validar_usuario(email, password):
    user = get_user_by_email(email)
    if user is None:
        return False

    password_hash = user['password_hash']
    return check_password_hash(password_hash, password)

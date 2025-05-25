# __init__.py
from flask import Flask
from flask_cors import CORS
from .config import Config
from .routes import auth_bp
import logging


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    CORS(app)

    logging.basicConfig(
        filename="app.log",  # Puedes cambiar el nombre o ruta
        level=logging.DEBUG,
        format='%(message)s',  # Dejamos el mensaje plano porque será JSON
    )

    # Registrar las rutas de autenticación
    app.register_blueprint(auth_bp)

    return app

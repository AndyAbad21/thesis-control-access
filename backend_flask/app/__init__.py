# __init__.py
from flask import Flask
from flask_cors import CORS
from .config import Config
from .routes import auth_bp

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    CORS(app)

    # Registrar las rutas de autenticación
    app.register_blueprint(auth_bp)

    return app

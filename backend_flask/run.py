# run.py
from app import create_app

app = create_app()

if __name__ == '__main__':
    print("Backend Flask iniciado en http://0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000)

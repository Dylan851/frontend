# Animal Go

Proyecto dividido en dos partes:
- Frontend: app Flutter
- Backend: API con FastAPI + PostgreSQL

## Frontend (Flutter)

Ruta: `frontend/`

### Requisitos
- Flutter 3.x
- Dart 3.x

### Ejecutar en local
```bash
flutter pub get
flutter run
```

### Build web
```bash
flutter build web --web-renderer=canvaskit
```

### Configuracion importante
- Revisar `lib/config/api_config.dart` para apuntar al backend correcto (local o Render).

## Backend (FastAPI)

Ruta: `backend/`

### Requisitos
- Python 3.11+
- PostgreSQL

### Ejecutar en local
```bash
python -m venv .venv
. .venv/Scripts/Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Documentacion API
- http://localhost:8000/docs
- http://localhost:8000/redoc

## Despliegue en Render

### Backend
- Crear un Web Service con el repo `backend`.
- Configurar variables de entorno del `.env.example`.
- Start command sugerido: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

### Frontend web
- Crear servicio estático con el repo `frontend`.
- Build command: `flutter build web --web-renderer=canvaskit`
- Publish directory: `build/web`

## Estructura general
- `frontend/`: cliente Flutter (UI, juego, assets)
- `backend/`: API, autenticacion y datos

# FastAPI Test API

Un simple API de prueba con FastAPI que retorna un estado "OK".

## Instalación

```bash
pip install -r requirements.txt
```

## Ejecución

```bash
python main.py
```

O usando uvicorn directamente:

```bash
uvicorn main:app --reload
```

## Endpoints

- `GET /` - Retorna `{"status": "OK"}`
- `GET /health` - Retorna `{"status": "OK"}`

## Documentación interactiva

Cuando el servidor está corriendo, accede a:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

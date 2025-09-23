from fastapi import FastAPI, Depends
from app import models
from app.database import engine
from app.routers import auth, machines
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, machines, admin
from app.auth import get_current_admin_user

app = FastAPI(
    title="PCQI API",
    description="API para a Plataforma de Controle de Qualidade Inteligente.",
    version="1.0.0"
)

origins = [
    "https://pcqi.onrender.com",
    "http://127.0.0.1:5500",
    "http://localhost:5500",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(machines.router, prefix="/api/v1/machines", tags=["Machines"],)
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"], dependencies=[Depends(get_current_admin_user)])

@app.get("/")
def read_root():
    return {"message": "Bem-vindo à API do PCQI v1!"}

# from app.routers import machines
# app.include_router(machines.router, prefix="/api/v1/machines", tags=["Machines"])
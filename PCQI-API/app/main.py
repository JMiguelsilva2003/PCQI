from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, machines, admin, users, sectors
from app.routers import stats

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
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])
app.include_router(machines.router, prefix="/api/v1/machines", tags=["Machines"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])
app.include_router(sectors.router, prefix="/api/v1/sectors", tags=["Sectors"])
app.include_router(stats.router, prefix="/api/v1/stats", tags=["Statistics"])


@app.get("/")
def read_root():
    return {"message": "Bem-vindo à API do PCQI v2!"}
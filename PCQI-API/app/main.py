from fastapi import FastAPI
from app import models
from app.database import engine
from app.routers import auth, machines 

models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="PCQI API",
    description="API para a Plataforma de Controle de Qualidade Inteligente.",
    version="1.0.0"
)

app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(machines.router, prefix="/api/v1/machines", tags=["Machines"],)

@app.get("/")
def read_root():
    return {"message": "Bem-vindo à API do PCQI v1!"}

# from app.routers import machines
# app.include_router(machines.router, prefix="/api/v1/machines", tags=["Machines"])
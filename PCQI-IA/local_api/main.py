from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from local_api.routers import prediction

app = FastAPI(
    title="PCQI Local AI API",
    description="API local para receber imagens e retornar predições da IA.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(prediction.router)
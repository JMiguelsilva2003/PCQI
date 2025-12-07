from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from local_api.routers import prediction 

app = FastAPI(
    title="PCQI AI API (Hugging Face)",
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

@app.get("/")
def read_root():
    return {"message": "API de IA do PCQI está online e pronta"}
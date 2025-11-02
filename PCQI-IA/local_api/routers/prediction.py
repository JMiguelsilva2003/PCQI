from fastapi import APIRouter, WebSocket, WebSocketDisconnect, HTTPException
import httpx
import asyncio
import os

from local_api.ml.processing import predict_image_from_bytes
from local_api.state_manager import AnalysisStateManager

router = APIRouter()

RENDER_API_URL = os.getenv()

MACHINE_ID_FOR_IA = os.getenv() 

RENDER_API_KEY = os.getenv() 

manager = AnalysisStateManager()

async def send_to_render_api(prediction: str):
    if not RENDER_API_URL or not RENDER_API_KEY:
        print("❌ERRO: Variáveis RENDER_API_URL ou RENDER_API_KEY não definidas.")
        return

    url = f"{RENDER_API_URL}/api/v1/machines/{MACHINE_ID_FOR_IA}/commands"
    headers = {"X-API-Key": RENDER_API_KEY, "Content-Type": "application/json"}
    data = {"prediction": prediction} 

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(url, headers=headers, json=data)
        
        if response.status_code == 201:
            print(f"Sucesso: Comando Único '{prediction}' enviado para o Render.")
        else:
            print(f"ERRO ao enviar para o Render: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"Exceção ao enviar para o Render: {e}")
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, HTTPException
import httpx
import asyncio
import os

from local_api.ml.processing import predict_image_from_bytes
from local_api.state_manager import AnalysisStateManager

router = APIRouter()

RENDER_API_URL = os.getenv("RENDER_API_URL")
MACHINE_ID_FOR_IA = os.getenv("MACHINE_ID_FOR_IA", "1") 
RENDER_API_KEY = os.getenv("HARDWARE_API_KEY")

manager = AnalysisStateManager()

async def send_to_render_api(prediction: str):
    if not RENDER_API_URL or not RENDER_API_KEY:
        print("❌ ERRO: Variáveis RENDER_API_URL ou RENDER_API_KEY não definidas.")
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

@router.websocket("/ws/predict")
async def websocket_predict(websocket: WebSocket):
    await websocket.accept()
    client_host = websocket.client.host
    print(f"Cliente (App) conectado: {client_host}")
    
    try:
        while True:
            image_bytes = await websocket.receive_bytes()
            
            try:
                result = predict_image_from_bytes(image_bytes)
                prediction = result.get("prediction")
            except Exception as e:
                print(f"Erro ao processar imagem: {e}")
                continue

            current_state, final_decision = manager.process_prediction(prediction)

            await websocket.send_json({
                "status": current_state,
                "current_prediction": prediction,
                "confidence": result.get("confidence")
            })

            if final_decision:
                asyncio.create_task(send_to_render_api(final_decision))
                
                await websocket.send_json({
                    "status": "Decidido",
                    "final_decision": final_decision
                })

    except WebSocketDisconnect:
        print(f"Cliente (App) {client_host} desconectado.")
        manager.reset()
    except Exception as e:
        print(f"Erro inesperado no WebSocket: {e}")
        await websocket.close(code=1011)
        manager.reset()
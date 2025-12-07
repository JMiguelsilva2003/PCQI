from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
import httpx
import asyncio
import os

from local_api.ml.processing import predict_image_from_bytes
from local_api.state_manager import AnalysisStateManager
from local_api.utils.collector import save_training_image

router = APIRouter()

RENDER_API_URL = os.getenv("RENDER_API_URL")
RENDER_API_KEY = os.getenv("HARDWARE_API_KEY") 

async def send_to_render_api(prediction: str, machine_id: int):
    if not RENDER_API_URL or not RENDER_API_KEY:
        print("❌ Variáveis de ambiente em falta.")
        return

    url = f"{RENDER_API_URL}/api/v1/machines/{machine_id}/commands"
    headers = {"X-API-Key": RENDER_API_KEY, "Content-Type": "application/json"}
    data = {"prediction": prediction} 

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(url, headers=headers, json=data)
            if response.status_code == 201:
                print(f"✅ Comando '{prediction}' enviado (Maq {machine_id})")
            else:
                print(f"❌ Erro Render: {response.status_code}")
    except Exception as e:
        print(f"❌ Exceção Render: {e}")

@router.websocket("/ws/predict")
async def websocket_predict(
    websocket: WebSocket,
    machine_id: int = Query(..., description="ID da Máquina")
):
    manager = AnalysisStateManager() 
    await websocket.accept()
    
    try:
        while True:
            image_bytes = await websocket.receive_bytes()
            
            try:
                result = predict_image_from_bytes(image_bytes)
                
                if result.get("prediction") == "ERRO_QUALIDADE":
                    await websocket.send_json({
                        "status": "Erro", 
                        "message": result["error"], 
                        "current_prediction": "DESFOCADA"
                    })
                    continue 

                prediction = result.get("prediction") 

            except Exception as e:
                print(f"Erro processamento: {e}")
                continue 

            current_state, final_decision = manager.process_prediction(prediction)

            if current_state == "Analisando" and prediction != "FUNDO":
                asyncio.create_task(save_training_image(image_bytes, prediction))

            await websocket.send_json({
                "status": current_state,
                "current_prediction": prediction,
                "confidence": result.get("confidence")
            })

            if final_decision:
                asyncio.create_task(send_to_render_api(final_decision, machine_id))
                await websocket.send_json({
                    "status": "Decidido",
                    "final_decision": final_decision
                })

    except WebSocketDisconnect:
        print(f"Cliente desconectado.")
    except Exception as e:
        print(f"Erro WebSocket: {e}")
        await websocket.close(code=1011)
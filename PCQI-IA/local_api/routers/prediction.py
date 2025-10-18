from fastapi import APIRouter, UploadFile, File, HTTPException
from local_api.ml.processing import predict_image_from_bytes
from local_api.hardware.arduino import send_command

router = APIRouter()

@router.post("/predict", summary="Recebe imagem, classifica e comanda o Arduino")
async def handle_prediction(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Formato de arquivo inválido.")

    try:
        contents = await file.read()
        result = predict_image_from_bytes(image_bytes=contents)
        
        if result["prediction"] == 'branco':
            send_command("REJECT")
        else:
            print(f"Peça '{result['prediction']}' aceita.")

        send_command("MOVE")

        return result
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao processar a imagem: {str(e)}")

@router.get("/", summary="Verifica o status da API")
def read_root():
    return {"status": "PCQI Local AI API está online e pronta!"}
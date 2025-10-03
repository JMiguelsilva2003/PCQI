from fastapi import APIRouter, UploadFile, File, HTTPException

from local_api.ml.processing import predict_image_from_bytes

router = APIRouter()

@router.post("/predict", summary="Recebe uma imagem e retorna a predição")
async def handle_prediction(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Formato de arquivo inválido. Por favor, envie uma imagem.")

    try:
        contents = await file.read()
        result = predict_image_from_bytes(image_bytes=contents)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao processar a imagem: {str(e)}")

@router.get("/", summary="Verifica o status da API")
def read_root():
    """Endpoint de 'health check' para saber se a API está online."""
    return {"status": "PCQI Local AI API está online e pronta!"}
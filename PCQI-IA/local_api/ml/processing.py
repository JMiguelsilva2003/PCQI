import torch
from PIL import Image
import io

from local_api.ml.model import model, device
from local_api.config import TRANSFORM, CLASSES

def predict_image_from_bytes(image_bytes: bytes) -> dict:
    """Recebe os bytes de uma imagem, processa com o modelo e retorna a predição."""
    try:
        image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    except Exception:
        raise ValueError("Conteúdo do arquivo não é uma imagem válida.")

    img_tensor = TRANSFORM(image).unsqueeze(0).to(device)
    
    with torch.no_grad():
        outputs = model(img_tensor)
        probabilities = torch.nn.functional.softmax(outputs, dim=1)
        confidence, predicted_idx = torch.max(probabilities, 1)
        
        predicted_class = CLASSES[predicted_idx.item()]
        confidence_percent = confidence.item() * 100

    return {
        "prediction": predicted_class,
        "confidence": f"{confidence_percent:.2f}%"
    }
import os
from datetime import datetime
import asyncio

BASE_DATASET_PATH = "dataset_v2"

async def save_training_image(image_bytes: bytes, prediction: str):
    
    try:
        today = datetime.now().strftime("%Y-%m-%d")
        folder_path = os.path.join(BASE_DATASET_PATH, today, prediction)
        os.makedirs(folder_path, exist_ok=True)
        
        filename = f"{int(datetime.now().timestamp() * 1000)}.jpg"
        file_path = os.path.join(folder_path, filename)
        
        await asyncio.to_thread(_write_file, file_path, image_bytes)

    except Exception as e:
        print(f"❌ Erro ao salvar imagem: {e}")

def _write_file(path, data):
    with open(path, "wb") as f:
        f.write(data)
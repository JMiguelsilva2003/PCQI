import cv2
import numpy as np

LIMITE_DESFOQUE = 100.0 

def check_image_quality(image_bytes: bytes) -> dict:
    
    try:
        nparr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            return {'valid': False, 'error': 'Imagem corrompida'}

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        score_foco = cv2.Laplacian(gray, cv2.CV_64F).var()

        if score_foco < LIMITE_DESFOQUE:
            return {
                'valid': False, 
                'error': f'Imagem desfocada (Score: {score_foco:.1f})'
            }

        return {'valid': True}

    except Exception as e:
        print(f"Erro na verificação de qualidade: {e}")
        return {'valid': True}
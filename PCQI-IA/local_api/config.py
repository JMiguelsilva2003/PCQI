import os
from torchvision import transforms

_CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_ROOT = os.path.abspath(os.path.join(_CURRENT_DIR, '..'))

MODELO_PATH = os.path.join(_PROJECT_ROOT, 'treino/modelo_manga_v1.pth')
CLASSES = ['fundo', 'madura', 'verde']
IMG_SIZE = 128
TRANSFORM = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

ARDUINO_PORT = 'COM3'
ARDUINO_BAUDRATE = 9600
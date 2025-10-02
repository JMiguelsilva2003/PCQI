import torch
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from treino.cnn import SimpleCNN
from local_api.config import MODELO_PATH, CLASSES

print("Carregando modelo de IA...")
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

model = SimpleCNN(num_classes=len(CLASSES))
model.load_state_dict(torch.load(MODELO_PATH, map_location=device))
model.to(device)
model.eval()

print(f"Modelo de IA carregado e pronto no dispositivo: {device}")
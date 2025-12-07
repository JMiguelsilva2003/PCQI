import torch
import os
from torchvision import transforms
from torch.utils.data import DataLoader
from sklearn.metrics import classification_report, confusion_matrix
import sys

_CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))

VALIDACAO_DIR = os.path.join(_CURRENT_DIR, 'dataset', 'dataset-validacao')
MODELO_PATH = os.path.join(_CURRENT_DIR, 'modelo_manga_v1.pth')

sys.path.append(_CURRENT_DIR)
from cnn import SimpleCNN, MangaDataset, IMG_SIZE

def validar():
    print(f"\n Configuração de Validação ")
    print(f"Diretório do Script: {_CURRENT_DIR}")
    print(f"Procurando Dataset em: {VALIDACAO_DIR}")
    print(f"Procurando Modelo em: {MODELO_PATH}")

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Usando dispositivo: {device}")
    
    transform = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])

    if not os.path.exists(VALIDACAO_DIR):
        print(f"ERRO CRÍTICO: A pasta '{VALIDACAO_DIR}' não existe.")
        return

    try:
        val_dataset = MangaDataset(root_dir=VALIDACAO_DIR, transform=transform)
    except Exception as e:
        print(f"Erro ao carregar dataset: {e}")
        return

    val_loader = DataLoader(val_dataset, batch_size=1, shuffle=False)
    
    print(f"Dataset carregado: {len(val_dataset)} imagens.")
    print(f"Classes encontradas: {val_dataset.class_to_idx}")

    num_classes = len(val_dataset.classes)
    model = SimpleCNN(num_classes=num_classes).to(device)
    
    if not os.path.exists(MODELO_PATH):
        print(f"ERRO CRÍTICO: O arquivo de modelo '{MODELO_PATH}' não foi encontrado.")
        return

    try:
        model.load_state_dict(torch.load(MODELO_PATH, map_location=device))
        print("Modelo carregado com sucesso!")
    except Exception as e:
        print(f"Erro ao carregar o modelo: {e}")
        return

    model.eval()
    
    all_preds = []
    all_labels = []
    
    print("\nIniciando validação (processando imagens)...")
    with torch.no_grad():
        for images, labels in val_loader:
            images = images.to(device)
            labels = labels.to(device)
            
            outputs = model(images)
            _, predicted = torch.max(outputs.data, 1)
            
            all_preds.extend(predicted.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())

    print("\n" + "="*30)
    print("RELATÓRIO DE PERFORMANCE")
    print("="*30)
    
    class_names = val_dataset.classes
    
    print("\n Matriz de Confusão ")
    cm = confusion_matrix(all_labels, all_preds)
    print(cm)
    
    print("\n Métricas Detalhadas ")
    print(classification_report(all_labels, all_preds, target_names=class_names))

if __name__ == "__main__":
    validar()
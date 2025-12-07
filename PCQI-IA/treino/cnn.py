import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms
from PIL import Image
import os
import sys

_CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(_CURRENT_DIR, 'dataset')

TREINO_DIR = os.path.join(DATA_DIR, 'dataset-treino')
VALIDACAO_DIR = os.path.join(DATA_DIR, 'dataset-validacao')

MODEL_SAVE_PATH = os.path.join(_CURRENT_DIR, 'modelo_manga_v1.pth')

NUM_EPOCHS = 15       # Quantas vezes a IA vê o dataset
BATCH_SIZE = 8        # Imagens por lote
LEARNING_RATE = 0.001 # Velocidade de aprendizado
IMG_SIZE = 128        # Tamanho da imagem (128x128)

class MangaDataset(Dataset):

    def __init__(self, root_dir, transform=None):
        self.root_dir = root_dir
        self.transform = transform
        
        if not os.path.exists(root_dir):
            raise RuntimeError(f"Pasta não encontrada: {root_dir}. Verifique a estrutura.")

        self.classes = sorted([d for d in os.listdir(root_dir) if os.path.isdir(os.path.join(root_dir, d))])
        self.class_to_idx = {cls_name: i for i, cls_name in enumerate(self.classes)}
        self.image_paths = self._get_image_paths()
        
        print(f"Dataset carregado de '{os.path.basename(root_dir)}': {len(self.image_paths)} imagens em {len(self.classes)} classes: {self.classes}")

    def _get_image_paths(self):
        paths = []
        for cls_name in self.classes:
            class_dir = os.path.join(self.root_dir, cls_name)
            if not os.path.isdir(class_dir):
                continue
                
            for img_name in os.listdir(class_dir):
                if img_name.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp')):
                    paths.append((os.path.join(class_dir, img_name), self.class_to_idx[cls_name]))
        return paths

    def __len__(self):
        return len(self.image_paths)

    def __getitem__(self, idx):
        img_path, label = self.image_paths[idx]
        try:
            image = Image.open(img_path).convert('RGB')
        except Exception as e:
            print(f"Erro ao ler imagem {img_path}: {e}")
            image = Image.new('RGB', (IMG_SIZE, IMG_SIZE))

        if self.transform:
            image = self.transform(image)
            
        return image, label

class SimpleCNN(nn.Module):
    def __init__(self, num_classes=3):
        super(SimpleCNN, self).__init__()
        self.conv1 = nn.Conv2d(in_channels=3, out_channels=16, kernel_size=3, padding=1)
        self.relu1 = nn.ReLU()
        self.pool1 = nn.MaxPool2d(kernel_size=2, stride=2)
        
        self.conv2 = nn.Conv2d(in_channels=16, out_channels=32, kernel_size=3, padding=1)
        self.relu2 = nn.ReLU()
        self.pool2 = nn.MaxPool2d(kernel_size=2, stride=2)
        
        self.flatten = nn.Flatten()
        
        in_features = 32 * (IMG_SIZE // 4) * (IMG_SIZE // 4)
        
        self.fc1 = nn.Linear(in_features=in_features, out_features=64)
        self.relu3 = nn.ReLU()
        self.fc2 = nn.Linear(in_features=64, out_features=num_classes)

    def forward(self, x):
        x = self.pool1(self.relu1(self.conv1(x)))
        x = self.pool2(self.relu2(self.conv2(x)))
        x = self.flatten(x)
        x = self.relu3(self.fc1(x))
        x = self.fc2(x)
        return x

if __name__ == '__main__':
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"--- Configuração ---")
    print(f"Dispositivo: {device}")
    print(f"Diretório Base: {DATA_DIR}")

    transform = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])

    print("\nCarregando Dados")
    try:
        train_dataset = MangaDataset(root_dir=TREINO_DIR, transform=transform)
    except RuntimeError as e:
        print(f"ERRO CRÍTICO: {e}")
        print(f"Certifique-se que criou a pasta '{TREINO_DIR}' e colocou as imagens lá.")
        sys.exit(1)

    try:
        val_dataset = MangaDataset(root_dir=VALIDACAO_DIR, transform=transform)
    except RuntimeError as e:
        print(f"ERRO CRÍTICO: {e}")
        print(f"Certifique-se que criou a pasta '{VALIDACAO_DIR}' e colocou as imagens lá.")
        sys.exit(1)

    if not train_dataset.image_paths or not val_dataset.image_paths:
        print("ERRO: Um dos datasets está vazio. Adicione imagens nas pastas.")
        sys.exit(1)

    if train_dataset.classes != val_dataset.classes:
        print(f"ERRO: Classes diferentes encontradas!")
        print(f"Treino: {train_dataset.classes}")
        print(f"Validação: {val_dataset.classes}")
        print("As pastas devem ser iguais em ambos os diretórios.")
        sys.exit(1)

    NUM_CLASSES = len(train_dataset.classes)
    model = SimpleCNN(num_classes=NUM_CLASSES).to(device)
    
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)
    
    train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False)

    print("\nIniciando o Treinamento")
    
    for epoch in range(NUM_EPOCHS):
        model.train()
        running_loss = 0.0
        for images, labels in train_loader:
            images, labels = images.to(device), labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()

        model.eval()
        correct = 0
        total = 0
        with torch.no_grad():
            for images, labels in val_loader:
                images, labels = images.to(device), labels.to(device)
                outputs = model(images)
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
        
        accuracy = 100 * correct / total
        avg_loss = running_loss / len(train_loader)
        print(f'Época [{epoch+1}/{NUM_EPOCHS}] | Perda: {avg_loss:.4f} | Acurácia Validação: {accuracy:.2f}%')

    print("\nTreinamento Concluído")

    torch.save(model.state_dict(), MODEL_SAVE_PATH)
    print(f"Modelo salvo com sucesso em: {MODEL_SAVE_PATH}")
    
    print("\nATENÇÃO: Atualize o seu config.py com esta lista de classes:")
    print(f"CLASSES = {train_dataset.classes}")
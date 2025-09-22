import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset, random_split
from torchvision import transforms
from PIL import Image
import os

# CONFIGURAÇÕES

DATA_DIR = 'dataset'
MODEL_SAVE_PATH = 'modelo_bw.pth'

# Parâmetros do Treinamento
NUM_EPOCHS = 15       # Quantas vezes o modelo verá todo o dataset
BATCH_SIZE = 8        # Quantas imagens processar de uma vez
LEARNING_RATE = 0.001 # Taxa de aprendizado do otimizador
IMG_SIZE = 128        # Todas as imagens serão redimensionadas para 128x128 pixels

class BrancoPretoDataset(Dataset):
    def _init_(self, root_dir, transform=None):
        self.root_dir = root_dir
        self.transform = transform
        self.classes = sorted(os.listdir(root_dir))
        self.class_to_idx = {cls_name: i for i, cls_name in enumerate(self.classes)}
        self.image_paths = self._get_image_paths()
        print(f"Dataset encontrado com {len(self.image_paths)} imagens em {len(self.classes)} classes: {self.classes}")

    def _get_image_paths(self):
        paths = []
        for cls_name in self.classes:
            class_dir = os.path.join(self.root_dir, cls_name)
            if os.path.isdir(class_dir):
                for img_name in os.listdir(class_dir):
                    paths.append((os.path.join(class_dir, img_name), self.class_to_idx[cls_name]))
        return paths

    def _len_(self):
        return len(self.image_paths)

    def _getitem_(self, idx):
        img_path, label = self.image_paths[idx]
        image = Image.open(img_path).convert('RGB')
        
        if self.transform:
            image = self.transform(image)
            
        return image, label

# ARQUITETURA DA CNN 

class SimpleCNN(nn.Module):
    def _init_(self, num_classes=2):
        super(SimpleCNN, self)._init_()
        self.conv1 = nn.Conv2d(in_channels=3, out_channels=16, kernel_size=3, padding=1)
        self.relu1 = nn.ReLU()
        self.pool1 = nn.MaxPool2d(kernel_size=2, stride=2)
        
        self.conv2 = nn.Conv2d(in_channels=16, out_channels=32, kernel_size=3, padding=1)
        self.relu2 = nn.ReLU()
        self.pool2 = nn.MaxPool2d(kernel_size=2, stride=2)
        
        self.flatten = nn.Flatten()
        
        self.fc1 = nn.Linear(in_features=32 * (IMG_SIZE//4) * (IMG_SIZE//4), out_features=64)
        self.relu3 = nn.ReLU()
        self.fc2 = nn.Linear(in_features=64, out_features=num_classes)

    def forward(self, x):
        x = self.pool1(self.relu1(self.conv1(x)))
        x = self.pool2(self.relu2(self.conv2(x)))
        x = self.flatten(x)
        x = self.relu3(self.fc1(x))
        x = self.fc2(x)
        return x

if _name_ == '_main_':
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Usando dispositivo: {device}")

    transform = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])

    full_dataset = BrancoPretoDataset(root_dir=DATA_DIR, transform=transform)

    train_size = int(0.8 * len(full_dataset))
    val_size = len(full_dataset) - train_size
    train_dataset, val_dataset = random_split(full_dataset, [train_size, val_size])

    train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False)
    
    model = SimpleCNN(num_classes=len(full_dataset.classes)).to(device)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)

    print("\n--- Iniciando o Treinamento ---")
    
    # Loop de treinamento
    for epoch in range(NUM_EPOCHS):
        model.train() # Coloca o modelo em modo de treinamento
        running_loss = 0.0
        for i, (images, labels) in enumerate(train_loader):
            images, labels = images.to(device), labels.to(device)
            
            optimizer.zero_grad()
            
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            loss.backward()
            
            optimizer.step()
            
            running_loss += loss.item()

        model.eval() # Coloca o modelo em modo de avaliação
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
        print(f'Época [{epoch+1}/{NUM_EPOCHS}], Perda (Loss): {running_loss/len(train_loader):.4f}, Acurácia na Validação: {accuracy:.2f}%')

    print("--- Treinamento Concluído ---")

    # Salva o modelo treinado
    torch.save(model.state_dict(), MODEL_SAVE_PATH)
    print(f"Modelo salvo com sucesso em: {MODEL_SAVE_PATH}")
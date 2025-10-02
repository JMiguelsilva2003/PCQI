from torchvision import transforms

MODELO_PATH = 'treino/modelo_bw.pth' 

CLASSES = ['preto', 'branco'] 

IMG_SIZE = 128

TRANSFORM = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])
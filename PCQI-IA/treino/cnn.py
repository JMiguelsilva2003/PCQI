import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms
from PIL import Image
import os

# 1. Dataset personalizado

class BrancoPretoDataset(Dataset): # Criando o Dataset
    def __init__(self, root_dir, transform=None): # Método construtor da Classe com os argumentos
        self.root_dir = root_dir
        self.transform = transform
          

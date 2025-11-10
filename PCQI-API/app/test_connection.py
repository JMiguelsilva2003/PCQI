import os
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()

url = os.getenv("DATABASE_URL")

if not url:
    raise ValueError("Variável DATABASE_URL não encontrada!")

engine = create_engine(url)

with engine.connect() as connection:
    print("Conexão bem-sucedida!")

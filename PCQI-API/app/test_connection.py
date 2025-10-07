from sqlalchemy import create_engine

url = "DATABASE_URL"
engine = create_engine(url)

try:
    with engine.connect() as conn:
        print("✅ Conectado com sucesso ao banco Supabase!")
except Exception as e:
    print("❌ Erro:", e)

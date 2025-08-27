from fastapi import FastAPI, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
import os

from . import models, crud
from .database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def verify_api_key(x_api_key: str = Header(...)):
    if x_api_key != os.getenv("API_KEY"):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid API Key")

@app.get("/")
def read_root():
    return {"message": "Bem-vindo à API do PCQI!"}

@app.post("/api/v1/machine/heartbeat", status_code=status.HTTP_200_OK, dependencies=[Depends(verify_api_key)])
def machine_heartbeat(db: Session = Depends(get_db)):
    crud.update_machine_heartbeat(db=db, machine_id=1)
    return {"status": "acknowledged"}
from sqlalchemy.orm import Session
from app import models, schemas
from app.security import hash_password

def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def create_user(db: Session, user: schemas.UserCreate):
    hashed_pass = hash_password(user.password)
    db_user = models.User(email=user.email, hashed_password=hashed_pass)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def update_machine_heartbeat(db: Session, machine_id: int):
    db_machine = db.query(models.Machine).filter(models.Machine.id == machine_id).first()
    
    if db_machine:
        db_machine.last_heartbeat = datetime.datetime.utcnow()
        db.commit()
    else:
        new_machine = models.Machine(id=machine_id)
        db.add(new_machine)
        db.commit()
        db.refresh(new_machine)
    return db_machine
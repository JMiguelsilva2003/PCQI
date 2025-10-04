from sqlalchemy.orm import Session
import datetime

from app import models, schemas
from app.security import hash_password

# Funções CRUD para Usuários

def get_user(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()

def create_user(db: Session, user: schemas.UserCreate):
    hashed_pass = hash_password(user.password)
    db_user = models.User(email=user.email, name=user.name, hashed_password=hashed_pass)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def update_user(db: Session, user: models.User, user_update: schemas.UserUpdate):
    update_data = user_update.model_dump(exclude_unset=True)
    if "password" in update_data:
        hashed_pass = hash_password(update_data["password"])
        update_data["hashed_password"] = hashed_pass
        del update_data["password"]
    for key, value in update_data.items():
        setattr(user, key, value)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

def update_user_password(db: Session, user: models.User, new_password: str):
    hashed_pass = hash_password(new_password)
    user.hashed_password = hashed_pass
    db.commit()
    db.refresh(user)
    return user

def activate_user(db: Session, user: models.User):
    user.is_active = True
    db.commit()
    db.refresh(user)
    return user

def update_user_role(db: Session, user: models.User, role: str):
    user.role = role
    db.commit()
    db.refresh(user)
    return user

# Funções CRUD para Setores

def get_sector(db: Session, sector_id: int):
    return db.query(models.Sector).filter(models.Sector.id == sector_id).first()

def get_sector_by_name(db: Session, name: str):
    return db.query(models.Sector).filter(models.Sector.name == name).first()

def get_all_sectors(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Sector).offset(skip).limit(limit).all()

def create_sector(db: Session, sector: schemas.SectorCreate):
    db_sector = models.Sector(**sector.model_dump())
    db.add(db_sector)
    db.commit()
    db.refresh(db_sector)
    return db_sector

def add_user_to_sector(db: Session, user: models.User, sector: models.Sector):
    sector.members.append(user)
    db.commit()
    db.refresh(sector)
    return sector

# Funções CRUD para Máquinas


def get_machine(db: Session, machine_id: int):
    return db.query(models.Machine).filter(models.Machine.id == machine_id).first()

def get_machines_for_user(db: Session, user: models.User):
    """Busca todas as máquinas de todos os setores dos quais um usuário é membro."""
    machines = []
    for sector in user.sectors:
        machines.extend(sector.machines)
    return machines

def create_machine_in_sector(db: Session, machine: schemas.MachineCreate, user_id: int):
    """Cria uma nova máquina e a associa a um setor e a um criador."""
    db_machine = models.Machine(name=machine.name, sector_id=machine.sector_id, creator_id=user_id)
    db.add(db_machine)
    db.commit()
    db.refresh(db_machine)
    return db_machine

def update_machine_heartbeat(db: Session, machine_id: int):
    """Atualiza o timestamp do último heartbeat de uma máquina existente."""
    db_machine = db.query(models.Machine).filter(models.Machine.id == machine_id).first()
    if db_machine:
        db_machine.last_heartbeat = datetime.datetime.now(datetime.timezone.utc)
        db.commit()
        db.refresh(db_machine)
    return db_machine
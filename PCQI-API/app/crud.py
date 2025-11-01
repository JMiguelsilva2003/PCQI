from sqlalchemy.orm import Session
from datetime import datetime, timezone
from typing import Optional

from app import models, schemas
from app.security import hash_password

# ==================================
# Funções CRUD para Usuários
# ==================================

def get_user(db: Session, user_id: int):
    """Busca um usuário pelo seu ID."""
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_user_by_email(db: Session, email: str):
    """Busca um usuário pelo seu email."""
    return db.query(models.User).filter(models.User.email == email).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    """Retorna uma lista de todos os usuários."""
    return db.query(models.User).offset(skip).limit(limit).all()

def create_user(db: Session, user: schemas.UserCreate):
    """Cria um novo usuário com a senha criptografada."""
    hashed_pass = hash_password(user.password)
    db_user = models.User(email=user.email, name=user.name, hashed_password=hashed_pass)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def update_user(db: Session, user: models.User, user_update: schemas.UserUpdate):
    """Atualiza os dados de um usuário (nome e/ou senha)."""
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
    """Atualiza a senha de um usuário."""
    hashed_pass = hash_password(new_password)
    user.hashed_password = hashed_pass
    db.commit()
    db.refresh(user)
    return user

def activate_user(db: Session, user: models.User):
    """Ativa a conta de um usuário (verificação de email)."""
    user.is_active = True
    db.commit()
    db.refresh(user)
    return user

def update_user_role(db: Session, user: models.User, role: str):
    """Atualiza a role de um usuário (ex: para 'admin')."""
    user.role = role
    db.commit()
    db.refresh(user)
    return user

# ==================================
# Funções CRUD para Setores
# ==================================

def get_sector(db: Session, sector_id: int):
    """Busca um setor pelo seu ID."""
    return db.query(models.Sector).filter(models.Sector.id == sector_id).first()

def get_sector_by_name(db: Session, name: str):
    """Busca um setor pelo seu nome."""
    return db.query(models.Sector).filter(models.Sector.name == name).first()

def get_all_sectors(db: Session, skip: int = 0, limit: int = 100):
    """Retorna todos os setores (para admins)."""
    return db.query(models.Sector).offset(skip).limit(limit).all()

def create_sector(db: Session, sector: schemas.SectorCreate):
    """Cria um novo setor."""
    db_sector = models.Sector(**sector.model_dump())
    db.add(db_sector)
    db.commit()
    db.refresh(db_sector)
    return db_sector

def add_user_to_sector(db: Session, user: models.User, sector: models.Sector):
    """Adiciona um usuário como membro de um setor."""
    sector.members.append(user)
    db.commit()
    db.refresh(sector)
    return sector

# ==================================
# Funções CRUD para Máquinas
# ==================================

def get_machine(db: Session, machine_id: int):
    """Busca uma única máquina pelo seu ID."""
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
        db_machine.last_heartbeat = datetime.now(timezone.utc)
        db.commit()
        db.refresh(db_machine)
    return db_machine

def create_machine_command(db: Session, machine_id: int, action: str) -> models.Command:
    """Adiciona um novo comando à fila de uma máquina."""
    db_command = models.Command(machine_id=machine_id, action=action)
    db.add(db_command)
    db.commit()
    db.refresh(db_command)
    return db_command

def get_next_pending_command(db: Session, machine_id: int) -> Optional[models.Command]:
    """
    Busca o comando pendente mais antigo de uma máquina,
    marca-o como 'processed' e o retorna.
    """
    command = db.query(models.Command).filter(
        models.Command.machine_id == machine_id,
        models.Command.status == "pending"
    ).order_by(models.Command.created_at).first()
    
    if command:
        command.status = "processed"
        db.commit()
        db.refresh(command)
        return command
    
    return None

# Funções para Stats

def get_command_stats(
    db: Session, 
    user: models.User, 
    sector_id: Optional[int] = None, 
    machine_id: Optional[int] = None
) -> schemas.StatsResponse:
    """
    Calcula as estatísticas de comandos (mangas analisadas) com base nas permissões
    do usuário e filtros opcionais.
    """
    
    query = db.query(
        func.count(models.Command.id).label("total"),
        func.sum(case((models.Command.action == 'MATURA', 1), else_=0)).label("maduras"),
        func.sum(case((models.Command.action == 'VERDE', 1), else_=0)).label("verdes"),
        func.sum(case((models.Command.action.notin_(['MATURA', 'VERDE']), 1), else_=0)).label("outras")
    ).join(models.Machine)

    if user.role != "admin":
        user_sector_ids = [sector.id for sector in user.sectors]
        query = query.filter(models.Machine.sector_id.in_(user_sector_ids))
    
    if machine_id:
        query = query.filter(models.Machine.id == machine_id)
    elif sector_id:
        if user.role == "admin" or sector_id in user_sector_ids:
            query = query.filter(models.Machine.sector_id == sector_id)
        else:
            return schemas.StatsResponse()

    stats = query.first()

    if not stats or stats.total is None:
        return schemas.StatsResponse()

    return schemas.StatsResponse(
        total=stats.total or 0,
        maduras=int(stats.maduras or 0),
        verdes=int(stats.verdes or 0),
        outras=int(stats.outras or 0)
    )

# Funções para Deletar

def delete_user(db: Session, user_id: int) -> Optional[models.User]:
    """ Deleta um usuário e limpa suas associações. """
    db_user = get_user(db, user_id)
    if not db_user:
        return None
    
    db.query(models.Machine).filter(
        models.Machine.creator_id == user_id
    ).update({"creator_id": None})
    
    db.delete(db_user)
    db.commit()
    return db_user

def delete_sector(db: Session, sector_id: int) -> Optional[models.Sector]:
    """ Deleta um setor."""
    db_sector = get_sector(db, sector_id)
    if not db_sector:
        return None

    if len(db_sector.machines) > 0:
        raise ValueError("Não é possível apagar o setor. Ele ainda contém máquinas.")
    
    db.delete(db_sector)
    db.commit()
    return db_sector


def delete_machine(db: Session, machine_id: int) -> Optional[models.Machine]:
    """ Deleta uma máquina. (Comandos associados são deletados em cascata) """
    db_machine = get_machine(db, machine_id)
    if not db_machine:
        return None
    
    db.delete(db_machine)
    db.commit()
    return db_machine
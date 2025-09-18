from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app import crud, models, schemas
from app.database import get_db
from app.auth import get_current_user
from app.routers import descriptions as desc

router = APIRouter()

@router.post(
    "/",
    response_model=schemas.Machine,
    status_code=status.HTTP_201_CREATED,
    summary="Cria uma nova máquina",
    description=desc.CREATE_MACHINE_DESCRIPTION
)
def create_machine_for_current_user(
    machine: schemas.MachineCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    return crud.create_user_machine(db=db, machine=machine, user_id=current_user.id)


@router.get(
    "/",
    response_model=List[schemas.Machine],
    summary="Lista as máquinas do usuário",
    description=desc.READ_USER_MACHINES_DESCRIPTION
)
def read_user_machines(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    machines = crud.get_machines_by_user(db, user_id=current_user.id)
    return machines


@router.get(
    "/{machine_id}",
    response_model=schemas.Machine,
    summary="Busca uma máquina específica",
    description=desc.READ_SPECIFIC_MACHINE_DESCRIPTION
)
def read_specific_machine(
    machine_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    db_machine = crud.get_machine(db, machine_id=machine_id)
    if db_machine is None:
        raise HTTPException(status_code=404, detail="Machine not found")
    
    if db_machine.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to access this machine")
        
    return db_machine
from fastapi import APIRouter, Depends, HTTPException, status, Response
from sqlalchemy.orm import Session
from typing import List

from app import crud, models, schemas
from app.database import get_db
from app.auth import get_current_user, verify_api_key
from app.routers import descriptions as desc

router = APIRouter()

# --- Rotas de Gestão de Máquinas (para Usuários)

@router.post(
    "/",
    response_model=schemas.Machine,
    status_code=status.HTTP_201_CREATED,
    summary="Cria uma nova máquina em um setor",
    description=desc.CREATE_MACHINE_DESCRIPTION
)
def create_machine(
    machine: schemas.MachineCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    Cria uma nova máquina associada a um setor.
    Apenas Admins ou membros do setor podem criar.
    """
    sector = crud.get_sector(db, sector_id=machine.sector_id)
    if not sector:
        raise HTTPException(status_code=404, detail="Sector not found")
    
    if current_user.role != "admin" and sector not in current_user.sectors:
        raise HTTPException(
            status_code=403, 
            detail="Not authorized to add machines to this sector"
        )

    return crud.create_machine_in_sector(db=db, machine=machine, user_id=current_user.id)


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
    """
    Retorna uma lista de todas as máquinas de todos os setores
    dos quais o usuário é membro.
    """
    return crud.get_machines_for_user(db=db, user=current_user)


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
    """
    Retorna os detalhes de uma máquina específica.
    Apenas Admins ou membros do setor da máquina podem acessar.
    """
    db_machine = crud.get_machine(db, machine_id=machine_id)
    if db_machine is None:
        raise HTTPException(status_code=404, detail="Machine not found")
    
    if current_user.role != "admin" and db_machine.sector not in current_user.sectors:
        raise HTTPException(
            status_code=403, 
            detail="Not authorized to access this machine"
        )
        
    return db_machine

# --- ROTAS DE COMANDO ---

@router.post(
    "/{machine_id}/commands",
    summary="A IA (ou App) reporta uma classificação",
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(verify_api_key)] 
)
def add_command_from_prediction(
    machine_id: int,
    request: schemas.AIPredictionRequest,
    db: Session = Depends(get_db)
):
    action = "REJECT" if request.prediction == "branco" else "ACCEPT"

    crud.create_machine_command(db=db, machine_id=machine_id, action=action)

    return {"message": "Command queued successfully"}

@router.get(
    "/{machine_id}/commands/next",
    response_model=schemas.Command,
    summary="O Gateway de Hardware busca o próximo comando",
    dependencies=[Depends(verify_api_key)]
)
def get_next_command(
    machine_id: int, 
    db: Session = Depends(get_db)
):
    """
    O Gateway de Hardware (script local) chama esta rota repetidamente (polling)
    para buscar a próxima ação pendente da fila.
    """
    command = crud.get_next_pending_command(db=db, machine_id=machine_id)
    
    if not command:
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    
    return command

# ROTA DELETE para Máquinas

@router.delete(
    "/{machine_id}",
    response_model=schemas.Machine,
    summary="Deleta uma máquina",
    description="Deleta uma máquina. O usuário deve ser o criador da máquina ou um administrador."
)
def delete_machine(
    machine_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    db_machine = crud.get_machine(db, machine_id=machine_id)
    if db_machine is None:
        raise HTTPException(status_code=404, detail="Máquina não encontrada.")

    if current_user.role != "admin" and db_machine.creator_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Você não tem permissão para deletar esta máquina."
        )
    
    deleted_machine = crud.delete_machine(db, machine_id=machine_id)
    if deleted_machine is None:
        raise HTTPException(status_code=404, detail="Máquina não encontrada durante a deleção.")

    return deleted_machine
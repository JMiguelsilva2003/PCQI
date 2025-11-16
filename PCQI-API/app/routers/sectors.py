from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app import crud, models, schemas
from app.database import get_db
from app.auth import get_current_user, get_current_admin_user

router = APIRouter()

@router.post(
    "/",
    response_model=schemas.Sector,
    status_code=status.HTTP_201_CREATED,
    summary="Cria um novo setor (Apenas Admin)"
)
def create_sector(
    sector: schemas.SectorCreate,
    db: Session = Depends(get_db),
    admin_user: models.User = Depends(get_current_admin_user)
):
    """
    Cria um novo setor global. Apenas administradores podem usar esta rota.
    """
    db_sector = crud.get_sector_by_name(db, name=sector.name)
    if db_sector:
        raise HTTPException(status_code=400, detail="Sector with this name already exists")
    return crud.create_sector(db=db, sector=sector)


@router.get(
    "/",
    response_model=List[schemas.Sector],
    summary="Lista os setores"
)
def read_sectors(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    Lista os setores.
    - Administradores veem todos os setores do sistema.
    - Usuários comuns veem apenas os setores dos quais são membros.
    """
    if current_user.role == "admin":
        return crud.get_all_sectors(db=db)
    else:
        return current_user.sectors


@router.post(
    "/{sector_id}/members",
    response_model=schemas.Sector,
    summary="Adiciona um usuário a um setor (Apenas Admin)"
)
def add_member_to_sector(
    sector_id: int,
    member_request: schemas.MemberAddRequest,
    db: Session = Depends(get_db),
    admin_user: models.User = Depends(get_current_admin_user)
):
    """
    Adiciona um usuário existente como membro de um setor.
    """
    user_to_add = crud.get_user(db, user_id=member_request.user_id)
    if not user_to_add:
        raise HTTPException(status_code=404, detail="User not found")
        
    sector = crud.get_sector(db, sector_id=sector_id)
    if not sector:
        raise HTTPException(status_code=404, detail="Sector not found")

    if user_to_add in sector.members:
        raise HTTPException(status_code=400, detail="User is already a member of this sector")

    return crud.add_user_to_sector(db=db, user=user_to_add, sector=sector)

# ROTA DELETE para Setores

@router.delete(
    "/{sector_id}",
    response_model=schemas.Sector,
    summary="Deleta um setor (Apenas Admin)",
    description="Deleta um setor do sistema. Por padrão, só permite apagar setores vazios (sem máquinas)."
)
def delete_sector(
    sector_id: int,
    db: Session = Depends(get_db),
    current_admin: models.User = Depends(get_current_admin_user)
):
    try:
        db_sector = crud.delete_sector(db, sector_id=sector_id)
        if db_sector is None:
            raise HTTPException(status_code=404, detail="Setor não encontrado.")
        return db_sector
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Erro interno ao deletar o setor.")

@router.delete(
    "/{sector_id}/members/{user_id}",
    response_model=schemas.Sector,
    summary="Remove um usuário de um setor (Apenas Admin)",
    description="Remove a associação de um usuário a um setor."
)
def remove_member_from_sector(
    sector_id: int,
    user_id: int,
    db: Session = Depends(get_db),
    current_admin: models.User = Depends(auth.get_current_admin_user)
):
    """ História: Remover Usuário de Setor  """
    sector = crud.get_sector(db, sector_id)
    if not sector:
        raise HTTPException(status_code=404, detail="Setor não encontrado.")
    
    user = crud.get_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="Usuário não encontrado.")

    if user not in sector.members:
        raise HTTPException(status_code=400, detail="Usuário não é membro deste setor.")

    return crud.remove_user_from_sector(db, user=user, sector=sector)
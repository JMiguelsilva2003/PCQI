from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional

from app import crud, models, schemas
from app.database import get_db
from app.routers.auth import get_current_user

router = APIRouter()

@router.get(
    "/", 
    response_model=schemas.StatsResponse,
    summary="Obtém estatísticas de classificação de mangas",
    description="Retorna o total de mangas analisadas, maduras e verdes. "
                "Administradores veem todas as estatísticas. "
                "Usuários comuns veem apenas dos seus setores. "
                "Os filtros (machine_id, sector_id) são aplicados."
)
def get_stats(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
    sector_id: Optional[int] = Query(None, description="Filtrar estatísticas por um ID de setor específico"),
    machine_id: Optional[int] = Query(None, description="Filtrar estatísticas por um ID de máquina específico")
):
    """
    Endpoint para buscar estatísticas de comandos.
    
    - Protegido por login.
    - Filtra automaticamente com base nas permissões do usuário.
    """
    stats = crud.get_command_stats(db, current_user, sector_id, machine_id)
    return stats
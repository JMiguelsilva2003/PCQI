from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional, List

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

@router.get(
    "/history", 
    response_model=List[schemas.StatsHistoryPoint],
    summary="Obtém estatísticas históricas ",
    description="Retorna uma lista de contagens 'MATURA' vs 'VERDE' agrupadas por dia."
)
def get_stats_history(
    range: int = Query(7, ge=1, le=30, description="Número de dias (1-30) para o histórico."),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    """ História: Estatísticas Históricas """
    stats_history = crud.get_stats_history(db, range_days=range)
    return stats_history

@router.get(
    "/performance_by_machine", 
    response_model=List[schemas.MachinePerformance],
    summary="Obtém ranking de performance por máquina",
    description="Retorna uma lista de todas as máquinas com suas contagens de 'MATURA' e 'VERDE'."
)
def get_stats_performance(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    """ História: Estatísticas por Máquina"""
    stats = crud.get_stats_performance_by_machine(db, user=current_user)
    return stats
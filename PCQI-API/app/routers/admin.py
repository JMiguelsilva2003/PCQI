from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app import crud, models, schemas
from app.database import get_db
from app.auth import get_current_admin_user

router = APIRouter()

@router.get(
    "/users",
    response_model=List[schemas.User],
    summary="Lista todos os usuários (Apenas Admin)",
    description="Retorna uma lista de todos os usuários do sistema. Apenas usuários com a role 'admin' podem acessar esta rota."
)
def read_users(
    db: Session = Depends(get_db),
    admin_user: models.User = Depends(get_current_admin_user)
):
    return crud.get_users(db=db)

@router.put(
    "/users/{user_id}/promote",
    response_model=schemas.User,
    summary="Promove um usuário para Admin (Apenas Admin)",
    description="Altera a role de um usuário específico para 'admin'. Apenas administradores podem realizar esta ação."
)
def promote_user_to_admin(
    user_id: int,
    db: Session = Depends(get_db),
    admin_user: models.User = Depends(get_current_admin_user)
):
    db_user = crud.get_user(db, user_id=user_id)
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return crud.update_user_role(db=db, user=db_user, role="admin")
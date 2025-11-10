from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.database import get_db
from app.auth import get_current_user
from app.routers import descriptions as desc

router = APIRouter()

@router.get(
    "/me", 
    response_model=schemas.User,
    summary="Obtém os dados do usuário atual",
    description="Retorna os dados do usuário que está atualmente logado, com base no token JWT enviado."
)
def read_users_me(current_user: models.User = Depends(get_current_user)):
    return current_user


@router.put(
    "/me",
    response_model=schemas.User,
    summary="Atualiza os dados do usuário atual",
    description="Atualiza o nome e/ou a senha do usuário atualmente logado. Apenas os campos fornecidos serão alterados."
)
def update_users_me(
    user_update: schemas.UserUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return crud.update_user(db=db, user=current_user, user_update=user_update)
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

# ROTA DELETE para Usuários


@router.delete(
    "/users/{user_id}",
    response_model=schemas.User,
    summary="Deleta um usuário (Apenas Admin)",
    description="Deleta um usuário do sistema. Remove suas associações de setor e anula seu 'creator_id' em máquinas."
)
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin: models.User = Depends(get_current_admin_user)
):
    if user_id == current_admin.id:
        raise HTTPException(
            status_code=400, detail="Administradores não podem deletar a si próprios.")

    db_user = crud.delete_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="Usuário não encontrado.")

    return db_user

# Rota para controle Mestre


@router.post(
    "/machines/{machine_id}/control",
    status_code=status.HTTP_201_CREATED,
    summary="Envia um comando de controle mestre (Apenas Admin)",
    description="Permite que um Administrador injete um comando manual "
                "(ex: 'EJECT_MANUAL', 'PAUSE') diretamente na fila de "
                "comandos de uma máquina específica."
)
def admin_control_machine(
    machine_id: int,
    request: schemas.MachineControlRequest,
    db: Session = Depends(get_db),
    current_admin: models.User = Depends(auth.get_current_admin_user)
):

    db_machine = crud.get_machine(db, machine_id=machine_id)
    if db_machine is None:
        raise HTTPException(status_code=404, detail="Máquina não encontrada.")

    valid_commands = ["EJECT_MANUAL", "PAUSE", "RESUME"]
    if request.command not in valid_commands:
        raise HTTPException(
            status_code=400,
            detail=f"Comando inválido. Comandos permitidos: {valid_commands}"
        )

    try:
        crud.create_machine_command(
            db=db,
            machine_id=machine_id,
            action=request.command
        )
        return {"message": f"Comando '{request.command}' enviado com sucesso para a máquina {machine_id}."}

    except Exception as e:
        print(f"Erro ao criar comando de admin: {e}")
        raise HTTPException(
            status_code=500, detail="Erro interno ao injetar comando.")

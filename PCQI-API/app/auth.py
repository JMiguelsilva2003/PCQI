from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from jose import JWTError, jwt

from app import crud, models, schemas
from app.database import get_db
from app.security import SECRET_KEY, ALGORITHM

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

def get_current_user(
    token: str = Depends(oauth2_scheme), 
    db: Session = Depends(get_db)
) -> models.User:
    """
    Decodifica o token JWT, extrai o email (sub) e retorna o
    objeto do usuário do banco de dados.
    Esta é a função que usaremos para proteger nossas rotas.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
        token_data = schemas.TokenData(email=email)
    except JWTError:
        raise credentials_exception
    
    user = crud.get_user_by_email(db, email=token_data.email)
    if user is None:
        raise credentials_exception
    return user

def get_current_admin_user(
    current_user: models.User = Depends(get_current_user)
) -> models.User:
    """
    Uma dependência que verifica se o usuário atual é um admin.
    """
    print(f"\n[DEBUG] Verificando permissão de admin para: {current_user.email}")
    print(f"[DEBUG] Role do usuário no banco: '{current_user.role}'")

    if current_user.role != "admin":
        print("[DEBUG] ACESSO NEGADO! Role não é 'admin'.")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="The user does not have enough privileges"
        )
    
    print("[DEBUG] ACESSO PERMITIDO! Role é 'admin'.")
    return current_user
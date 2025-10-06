from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from jose import JWTError, jwt

from app import crud, models, schemas
from app.database import get_db
from app.security import (
    SECRET_KEY, ALGORITHM,
    verify_password,
    create_access_token,
    create_refresh_token,
    pwd_context
)
from app.routers import descriptions as desc
from app.services.email_service import send_verification_email, send_password_reset_email
from app.auth import get_current_user

router = APIRouter()

@router.post(
    "/register",
    response_model=schemas.User,
    summary="Cria um novo usuário",
    description=desc.REGISTER_USER_DESCRIPTION
)
def register_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    new_user = crud.create_user(db=db, user=user)
    
    try:
        send_verification_email(email=new_user.email)
    except Exception as e:
        print(f"Alerta: Falha ao enviar email de verificação para {new_user.email}. Erro: {e}")
        
    return new_user

@router.get("/verify-email", summary="Verifica o email do usuário")
def verify_email(token: str, db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid verification token"
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
        
        user = crud.get_user_by_email(db, email=email)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        
        if user.is_active:
            return {"message": "Email already verified"}
        
        crud.activate_user(db=db, user=user)
        return {"message": "Email verified successfully!"}
        
    except JWTError:
        raise credentials_exception

@router.post(
    "/login",
    response_model=schemas.Token,
    summary="Realiza o login e retorna os tokens",
    description=desc.LOGIN_TOKEN_DESCRIPTION
)
def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), 
    db: Session = Depends(get_db)
):
    user = crud.get_user_by_email(db, email=form_data.username)
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if pwd_context.needs_update(user.hashed_password):
        # Se precisar, atualiza a senha no banco para o novo formato (argon2)
        crud.update_user_password(db, user=user, new_password=form_data.password)
        print(f"Senha do usuário {user.email} foi atualizada para o novo formato.")
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email has not been verified"
        )
    
    access_token = create_access_token(data={"sub": user.email})
    refresh_token = create_refresh_token(data={"sub": user.email})
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post(
    "/refresh",
    response_model=schemas.Token,
    summary="Renova o token de acesso",
    description="Envia um refresh token válido para obter um novo par de access e refresh tokens."
)
def refresh_access_token(current_user: models.User = Depends(get_current_user)):
    
    access_token = create_access_token(data={"sub": current_user.email})
    refresh_token = create_refresh_token(data={"sub": current_user.email})
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/forgot-password", summary="Solicita a redefinição de senha")
def forgot_password(
    request: schemas.ForgotPasswordRequest,
    db: Session = Depends(get_db)
):
    user = crud.get_user_by_email(db, email=request.email)
    
    if user:
        try:
            send_password_reset_email(email=user.email)
        except Exception:
            pass 
            
    return {"message": "Se um usuário com este email existir, um link de redefinição foi enviado."}


@router.post("/reset-password", summary="Realiza a redefinição de senha")
def reset_password(
    request: schemas.ResetPasswordRequest,
    db: Session = Depends(get_db)
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired token"
    )
    try:
        payload = jwt.decode(request.token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
        
        user = crud.get_user_by_email(db, email=email)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        
        crud.update_user_password(db=db, user=user, new_password=request.new_password)
        
        return {"message": "Password has been reset successfully."}
        
    except JWTError:
        raise credentials_exception
from datetime import datetime
from typing import Optional, List, Annotated
from pydantic import BaseModel, ConfigDict, Field

# Schemas de Usuário e Autenticação

class UserBase(BaseModel):
    email: str
    name: str 

class UserCreate(UserBase):
    password: Annotated[str, Field(..., min_length=8)]

class User(UserBase):
    id: int
    created_at: datetime
    role: str
    is_active: bool
    model_config = ConfigDict(from_attributes=True)

class UserUpdate(BaseModel):
    name: Optional[str] = None
    password: Optional[Annotated[str, Field(..., min_length=8)]] = None

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

class ForgotPasswordRequest(BaseModel):
    email: str

class ResetPasswordRequest(BaseModel):
    token: str
    new_password: Annotated[str, Field(..., min_length=8)]

# Schemas para Máquina

class MachineBase(BaseModel):
    name: str

class MachineCreate(MachineBase):
    sector_id: int

class Machine(MachineBase):
    id: int
    sector_id: int
    creator_id: int
    model_config = ConfigDict(from_attributes=True)

# Schemas para Setor

class SectorBase(BaseModel):
    name: str
    description: Optional[str] = None

class SectorCreate(SectorBase):
    pass

class Sector(SectorBase):
    id: int
    machines: List[Machine] = []
    model_config = ConfigDict(from_attributes=True)

class MemberAddRequest(BaseModel):
    user_id: int
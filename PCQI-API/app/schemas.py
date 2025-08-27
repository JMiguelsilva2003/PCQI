from pydantic import BaseModel
from datetime import datetime
from typing import Optional

# schemas dos users
class UserBase(BaseModel):
    email: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

# schemas das maquinas
class MachineBase(BaseModel):
    name: str

class MachineCreate(MachineBase):
    pass

class Machine(MachineBase):
    id: int
    owner_id: int
    current_speed_ppm: int

    class Config:
        from_attributes = True
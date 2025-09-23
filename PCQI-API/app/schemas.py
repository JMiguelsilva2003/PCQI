from pydantic import BaseModel, ConfigDict, Field
from datetime import datetime
from typing import Optional, Annotated

# schemas dos users
class UserBase(BaseModel):
    email: str
    name: str 

class UserCreate(UserBase):
    password: Annotated[str, Field(..., min_length=8)]

class User(UserBase):
    id: int
    created_at: datetime
    role: str

    model_config = ConfigDict(from_attributes=True)

class Token(BaseModel):
    access_token: str
    refresh_token: str
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

    model_config = ConfigDict(from_attributes=True)
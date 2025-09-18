from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, JSON, Boolean
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime, timezone 

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    role = Column(String, default="user")
    machines = relationship("Machine", back_populates="owner")

class Machine(Base):
    __tablename__ = "machines"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    
    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User", back_populates="machines")
    current_speed_ppm = Column(Integer, default=60)
    last_heartbeat = Column(DateTime, default=lambda: datetime.now(timezone.utc)) 


from sqlalchemy import Table, Column, Integer, String, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime, timezone

sector_memberships = Table('sector_memberships', Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id'), primary_key=True),
    Column('sector_id', Integer, ForeignKey('sectors.id'), primary_key=True)
)

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, index=True)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    role = Column(String, default="user")
    is_active = Column(Boolean, default=False)
    
    sectors = relationship("Sector", secondary=sector_memberships, back_populates="members")

class Sector(Base):
    __tablename__ = "sectors"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    description = Column(String, nullable=True)
    
    machines = relationship("Machine", back_populates="sector")
    members = relationship("User", secondary=sector_memberships, back_populates="sectors")

class Machine(Base):
    __tablename__ = "machines"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    
    last_heartbeat = Column(DateTime, nullable=True)
    
    creator_id = Column(Integer, ForeignKey("users.id")) 
    sector_id = Column(Integer, ForeignKey("sectors.id"))

    sector = relationship("Sector", back_populates="machines")
    creator = relationship("User")
    
    commands = relationship("Command", back_populates="machine", cascade="all, delete-orphan")

class Command(Base):
    __tablename__ = "commands"

    id = Column(Integer, primary_key=True, index=True)
    action = Column(String, nullable=False)
    status = Column(String, default="pending", index=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    machine_id = Column(Integer, ForeignKey("machines.id"), nullable=False)
    machine = relationship("Machine", back_populates="commands")
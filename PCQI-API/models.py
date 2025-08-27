from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, JSON, Boolean
from sqlalchemy.orm import relationship
from .database import Base
import datetime

class Machine(Base):
    __tablename__ = "machines"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, default="PCQI-Linha-01")
    last_heartbeat = Column(DateTime, default=datetime.datetime.utcnow)

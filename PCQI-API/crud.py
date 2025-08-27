from sqlalchemy.orm import Session
from . import models
import datetime

def update_machine_heartbeat(db: Session, machine_id: int):
    db_machine = db.query(models.Machine).filter(models.Machine.id == machine_id).first()
    
    if db_machine:
        db_machine.last_heartbeat = datetime.datetime.utcnow()
        db.commit()
    else:
        new_machine = models.Machine(id=machine_id)
        db.add(new_machine)
        db.commit()
        db.refresh(new_machine)
    return db_machine
from sqlalchemy.orm import Session, joinedload
import models

def criar_gasto(db: Session, gasto: models.Gasto):
    db.add(gasto)
    return gasto
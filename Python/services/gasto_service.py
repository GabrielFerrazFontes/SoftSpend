from fastapi import HTTPException
from sqlalchemy.orm import Session
import models, schemas
from repositories import gasto_repository

def criar_gasto(db: Session, dia_id: int, gasto: schemas.GastoCreate):
    
    dia = db.query(models.Dia).filter(models.Dia.id == dia_id).first()

    if not dia:
        raise HTTPException(status_code=404, detail="Dia não encontrado")

    novo_gasto = models.Gasto(
        titulo=gasto.titulo,
        valor=gasto.valor,
        dia_id=dia_id
    )

    gasto_repository.criar_gasto(db, novo_gasto)

    dia.saldo -= gasto.valor

    dia.ciclo.gasto_total += gasto.valor

    db.commit()
    db.refresh(novo_gasto)

    return novo_gasto
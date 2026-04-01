from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from dtos.gasto import GastoResponse, GastoRequest
from services import gasto_service

router = APIRouter()

@router.post("/dias/{dia_id}/gastos", response_model=GastoResponse)
def criar_gasto(dia_id: int, gasto: GastoRequest, db: Session = Depends(get_db)):
    return gasto_service.criar_gasto(db, dia_id, gasto)

@router.delete("/gastos/{gasto_id}", status_code = 204)
def deletar_gasto(gasto_id: int, db: Session = Depends(get_db)):
    return gasto_service.remover_gasto(db, gasto_id)